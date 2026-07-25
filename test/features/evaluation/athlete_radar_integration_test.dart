import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/app.dart';
import 'package:performance_analytics/core/database/database_provider.dart';
import 'package:performance_analytics/core/database/local_database.dart';
import 'package:performance_analytics/main.dart' as app_main;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    app_main.teamSetupComplete = true;

    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'p1', name: '横田向星', grade: 2, position: const Value('G')),
        );
    final sessionId = 'session1';
    await db.into(db.measurementSessions).insert(
          MeasurementSessionsCompanion.insert(id: sessionId, measurementDate: DateTime(2026, 4, 1)),
        );
    // 高い評価が付くよう、G基準のレベル5相当の値を3項目分入力する
    // (side_step: agility, vertical_jump: explosivePower, sit_and_reach: flexibility)
    for (final entry in {
      'side_step': 65.0,
      'vertical_jump': 65.0,
      'sit_and_reach': 60.0,
    }.entries) {
      await db.into(db.measurementRecords).insert(
            MeasurementRecordsCompanion.insert(
              id: 'rec_${entry.key}',
              athleteId: 'p1',
              sessionId: sessionId,
              itemId: entry.key,
              value: entry.value,
            ),
          );
    }
  });

  tearDown(() => db.close());

  testWidgets('選手詳細画面で能力レーダーが実データから描画される', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PerformanceAnalyticsApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('選手'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('横田向星'));
    await tester.pumpAndSettle();

    expect(find.text('能力レーダー'), findsOneWidget);
    expect(find.byType(RadarChart), findsOneWidget);
  });
}
