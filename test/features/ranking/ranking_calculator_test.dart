import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/core/database/local_database.dart';
import 'package:performance_analytics/features/ranking/domain/ranking_calculator.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  group('RankingCalculator.computeItemRanking', () {
    test('higherIsBetterな項目は値が大きい順に順位付けされ、同値は同順位', () async {
      final items = await db.select(db.measurementItems).get();
      final verticalJump = items.firstWhere((i) => i.key == 'vertical_jump');

      final athletes = await Future.wait([
        _insertAthlete(db, 'a1', '選手A'),
        _insertAthlete(db, 'a2', '選手B'),
        _insertAthlete(db, 'a3', '選手C'),
      ]);

      final records = [
        _record('r1', 'a1', 'vertical_jump', 70),
        _record('r2', 'a2', 'vertical_jump', 60),
        _record('r3', 'a3', 'vertical_jump', 60),
      ];

      final ranking = RankingCalculator.computeItemRanking(
        athletes: athletes,
        item: verticalJump,
        records: records,
      );

      expect(ranking[0].athlete.id, 'a1');
      expect(ranking[0].rank, 1);
      expect(ranking[1].rank, 2); // 60cmの2人は同順位
      expect(ranking[2].rank, 2);
    });

    test('higherIsBetter=false（タイム系）は値が小さい順に順位付けされる', () async {
      final items = await db.select(db.measurementItems).get();
      final sprint = items.firstWhere((i) => i.key == 'three_quarter_sprint');

      final athletes = await Future.wait([
        _insertAthlete(db, 'a1', '選手A'),
        _insertAthlete(db, 'a2', '選手B'),
      ]);

      final records = [
        _record('r1', 'a1', 'three_quarter_sprint', 3.5),
        _record('r2', 'a2', 'three_quarter_sprint', 3.2),
      ];

      final ranking = RankingCalculator.computeItemRanking(
        athletes: athletes,
        item: sprint,
        records: records,
      );

      expect(ranking.first.athlete.id, 'a2'); // 速い(小さい)方が1位
    });

    test('記録が無い選手はランキングに含まれない', () async {
      final items = await db.select(db.measurementItems).get();
      final verticalJump = items.firstWhere((i) => i.key == 'vertical_jump');

      final athletes = await Future.wait([
        _insertAthlete(db, 'a1', '選手A'),
        _insertAthlete(db, 'a2', '選手B（未測定）'),
      ]);

      final ranking = RankingCalculator.computeItemRanking(
        athletes: athletes,
        item: verticalJump,
        records: [_record('r1', 'a1', 'vertical_jump', 60)],
      );

      expect(ranking.length, 1);
      expect(ranking.single.athlete.id, 'a1');
    });
  });

  group('RankingCalculator.computeOverallRanking', () {
    test('複数項目・異なる単位の偏差値平均で総合順位を算出する', () async {
      final items = await db.select(db.measurementItems).get();

      final athletes = await Future.wait([
        _insertAthlete(db, 'a1', '選手A'),
        _insertAthlete(db, 'a2', '選手B'),
      ]);

      // a1は垂直跳び・3/4コートスプリントともに好記録、a2は両方平凡
      final records = [
        _record('r1', 'a1', 'vertical_jump', 70), // 高いほど良い
        _record('r2', 'a2', 'vertical_jump', 50),
        _record('r3', 'a1', 'three_quarter_sprint', 3.0), // 低いほど良い
        _record('r4', 'a2', 'three_quarter_sprint', 3.8),
      ];

      final ranking = RankingCalculator.computeOverallRanking(
        athletes: athletes,
        items: items,
        records: records,
      );

      expect(ranking.first.athlete.id, 'a1');
      expect(ranking.first.rank, 1);
      expect(ranking.first.itemCount, 2);
      expect(ranking.first.averageDeviationScore, greaterThan(50));
      expect(ranking.last.averageDeviationScore, lessThan(50));
    });

    test('1項目も測定していない選手は総合順位に含まれない', () async {
      final items = await db.select(db.measurementItems).get();

      final athletes = await Future.wait([
        _insertAthlete(db, 'a1', '選手A'),
        _insertAthlete(db, 'a2', '未測定選手'),
      ]);

      final ranking = RankingCalculator.computeOverallRanking(
        athletes: athletes,
        items: items,
        records: [_record('r1', 'a1', 'vertical_jump', 60)],
      );

      expect(ranking.length, 1);
      expect(ranking.single.athlete.id, 'a1');
    });
  });
}

Future<Athlete> _insertAthlete(AppDatabase db, String id, String name) async {
  await db.into(db.athletes).insert(AthletesCompanion.insert(id: id, name: name, grade: 2));
  return (db.select(db.athletes)..where((t) => t.id.equals(id))).getSingle();
}

MeasurementRecord _record(String id, String athleteId, String itemId, double value) {
  return MeasurementRecord(
    id: id,
    athleteId: athleteId,
    sessionId: 'session1',
    itemId: itemId,
    value: value,
  );
}
