import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/core/database/local_database.dart';
import 'package:performance_analytics/features/athletes/data/local_athlete_repository.dart';
import 'package:performance_analytics/features/evaluation/data/local_evaluation_criteria_repository.dart';
import 'package:performance_analytics/features/measurements/data/local_measurement_repository.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  group('seed data', () {
    test('初期14測定項目が投入される', () async {
      final items = await db.select(db.measurementItems).get();
      expect(items, hasLength(14));
    });

    test('評価基準とスコアバンドが投入される', () async {
      final criteria = await db.select(db.evaluationCriteria).get();
      final bands = await db.select(db.scoreBands).get();
      expect(criteria, hasLength(20)); // ポジション別6項目×3 + 共通2項目
      expect(bands, hasLength(100)); // 20基準 × 5段階
    });
  });

  group('AthleteRepository', () {
    test('選手を作成し一覧に反映され、非活性化すると一覧から外れる', () async {
      final repo = LocalAthleteRepository(db);
      final id = await repo.create(
        AthletesCompanion.insert(id: 'a1', name: '山田太郎', grade: 2),
      );

      final active = await repo.getAll();
      expect(active.map((a) => a.id), contains(id));

      await repo.deactivate(id);
      final afterDeactivate = await repo.getAll();
      expect(afterDeactivate.map((a) => a.id), isNot(contains(id)));
    });
  });

  group('MeasurementRepository', () {
    test('同一選手×セッション×項目のupsertは上書きされ重複しない', () async {
      final athleteRepo = LocalAthleteRepository(db);
      final measurementRepo = LocalMeasurementRepository(db);

      final athleteId = await athleteRepo.create(
        AthletesCompanion.insert(id: 'a2', name: '佐藤次郎', grade: 1),
      );
      final sessionId = await measurementRepo.createSession(
        measurementDate: DateTime(2026, 4, 1),
        label: '2026年度 春季測定',
      );

      await measurementRepo.upsertRecord(
        athleteId: athleteId,
        sessionId: sessionId,
        itemId: 'vertical_jump',
        value: 60,
      );
      await measurementRepo.upsertRecord(
        athleteId: athleteId,
        sessionId: sessionId,
        itemId: 'vertical_jump',
        value: 65,
      );

      final records = await measurementRepo.getRecordsForAthlete(athleteId);
      expect(records, hasLength(1));
      expect(records.single.value, 65);
    });
  });

  group('EvaluationCriteriaRepository', () {
    test('高い記録は5、低い記録は1と評価される（値が大きいほど良い項目）', () async {
      final repo = LocalEvaluationCriteriaRepository(db);
      expect(
        await repo.evaluate(itemKey: 'vertical_jump', value: 80, position: 'G'),
        5,
      );
      expect(
        await repo.evaluate(itemKey: 'vertical_jump', value: 30, position: 'G'),
        1,
      );
    });

    test('タイム系（値が小さいほど良い項目）も正しく評価される', () async {
      final repo = LocalEvaluationCriteriaRepository(db);
      expect(
        await repo.evaluate(itemKey: 'lane_agility', value: 10.5, position: 'G'),
        5,
      );
      expect(
        await repo.evaluate(itemKey: 'lane_agility', value: 15.0, position: 'G'),
        1,
      );
    });

    test('ポジションによって同じ実測値でも評価が変わる', () async {
      final repo = LocalEvaluationCriteriaRepository(db);
      // 反復横跳び59回: G目標65(レベル3) / F目標60(レベル4) / C目標58(レベル5)
      expect(await repo.evaluate(itemKey: 'side_step', value: 59, position: 'G'), 3);
      expect(await repo.evaluate(itemKey: 'side_step', value: 59, position: 'F'), 4);
      expect(await repo.evaluate(itemKey: 'side_step', value: 59, position: 'C'), 5);
    });

    test('ポジション共通の基準はpositionを渡さなくても評価できる', () async {
      final repo = LocalEvaluationCriteriaRepository(db);
      expect(await repo.evaluate(itemKey: 'sit_and_reach', value: 62), 5);
    });

    test('評価基準が存在しない項目はnull（評価なし）を返す', () async {
      final repo = LocalEvaluationCriteriaRepository(db);
      expect(
        await repo.evaluate(itemKey: 'height', value: 180),
        isNull,
      );
      expect(
        await repo.evaluate(itemKey: 'pull_up', value: 10),
        isNull,
      );
    });
  });
}
