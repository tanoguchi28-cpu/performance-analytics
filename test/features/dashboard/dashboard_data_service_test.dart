import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/core/database/database_provider.dart';
import 'package:performance_analytics/core/database/local_database.dart';
import 'package:performance_analytics/features/dashboard/data/dashboard_data_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  Future<void> seedAthlete(String id, String name, {String? position, int grade = 2}) {
    return db.into(db.athletes).insert(
          AthletesCompanion.insert(
            id: id,
            name: name,
            grade: grade,
            position: Value(position),
          ),
        );
  }

  Future<String> seedSession(DateTime date) async {
    final id = 'session_${date.millisecondsSinceEpoch}';
    await db.into(db.measurementSessions).insert(
          MeasurementSessionsCompanion.insert(id: id, measurementDate: date),
        );
    return id;
  }

  Future<void> seedRecord(String athleteId, String sessionId, String itemId, double value) {
    return db.into(db.measurementRecords).insert(
          MeasurementRecordsCompanion.insert(
            id: 'rec_${athleteId}_${sessionId}_$itemId',
            athleteId: athleteId,
            sessionId: sessionId,
            itemId: itemId,
            value: value,
          ),
        );
  }

  test('選手が0人・セッションが無い場合は空のダッシュボードデータを返す', () async {
    final data = await container.read(dashboardDataProvider.future);

    expect(data.summary.athleteCount, 0);
    expect(data.summary.latestSessionDate, isNull);
    expect(data.summary.completionRate, 0);
    // ランキング対象の測定項目自体はマスタに存在するので、セクションは残るがentriesは空になる
    expect(data.rankings, isNotEmpty);
    expect(data.rankings.every((r) => r.entries.isEmpty), isTrue);
    expect(data.missingAthletes, isEmpty);
  });

  test('サマリー・ランキング・測定漏れ・チーム能力を正しく集計する', () async {
    await seedAthlete('a1', '選手A', position: 'G');
    await seedAthlete('a2', '選手B', position: 'C');
    final sessionId = await seedSession(DateTime(2026, 4, 1));

    // a1は身長・垂直跳びのみ入力(measurement漏れあり)、a2は身長のみ
    await seedRecord('a1', sessionId, 'height', 170);
    await seedRecord('a1', sessionId, 'vertical_jump', 65);
    await seedRecord('a2', sessionId, 'height', 180);

    final data = await container.read(dashboardDataProvider.future);

    expect(data.summary.athleteCount, 2);
    expect(data.summary.latestSessionDate, DateTime(2026, 4, 1));
    expect(data.summary.avgHeight, closeTo(175, 1e-9)); // (170+180)/2

    // 垂直跳びランキングにはa1のみ
    final verticalJumpRanking = data.rankings.firstWhere((r) => r.itemKey == 'vertical_jump');
    expect(verticalJumpRanking.entries.length, 1);
    expect(verticalJumpRanking.entries.first.athlete.name, '選手A');

    // 全14項目のうち2件しか埋まっていない選手がいるので両者とも測定漏れ扱い
    expect(data.missingAthletes.map((a) => a.name), containsAll(['選手A', '選手B']));

    // a1はG基準で65cmの垂直跳び=レベル5評価がつくため、チーム能力(explosivePower)にデータが入る
    final explosivePower = data.teamAbilityProfile.scores
        .firstWhere((s) => s.category.name == 'explosivePower');
    expect(explosivePower.hasData, isTrue);
  });

  test('前回セッションとの比較で改善ランキング・アラートが算出される', () async {
    await seedAthlete('a1', '選手A', position: 'G');
    final previousSessionId = await seedSession(DateTime(2026, 4, 1));
    final latestSessionId = await seedSession(DateTime(2026, 5, 1));

    await seedRecord('a1', previousSessionId, 'vertical_jump', 50);
    await seedRecord('a1', latestSessionId, 'vertical_jump', 40); // 悪化(higherIsBetter=true)

    final data = await container.read(dashboardDataProvider.future);

    expect(data.topDeclined, isNotEmpty);
    expect(data.topDeclined.first.athlete.name, '選手A');
    expect(data.topDeclined.first.avgPercentChange, lessThan(0));

    // (40-50)/50*100 = -20% は閾値-10%を超えているのでアラート対象
    expect(data.significantDeclines, isNotEmpty);
    expect(data.significantDeclines.first.athlete.name, '選手A');
  });
}
