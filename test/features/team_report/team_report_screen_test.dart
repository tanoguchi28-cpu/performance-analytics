import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
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
          AthletesCompanion.insert(id: 'a1', name: '横田向星', grade: 1, position: const Value('G')),
        );
    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'a2', name: '小森瑛太', grade: 2, position: const Value('F')),
        );
    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'a3', name: '山田太郎', grade: 3, position: const Value('C')),
        );

    const sessionId = 'session1';
    await db.into(db.measurementSessions).insert(
          MeasurementSessionsCompanion.insert(id: sessionId, measurementDate: DateTime(2026, 4, 1)),
        );

    final records = [
      ('r1', 'a1', 'vertical_jump', 65.0),
      ('r2', 'a2', 'vertical_jump', 55.0),
      ('r3', 'a3', 'vertical_jump', 45.0),
      ('r4', 'a1', 'three_quarter_sprint', 3.1),
      ('r5', 'a2', 'three_quarter_sprint', 3.4),
      ('r6', 'a3', 'three_quarter_sprint', 3.7),
    ];
    for (final (id, athleteId, itemKey, value) in records) {
      await db.into(db.measurementRecords).insert(
            MeasurementRecordsCompanion.insert(
              id: id,
              athleteId: athleteId,
              sessionId: sessionId,
              itemId: itemKey,
              value: value,
            ),
          );
    }
  });

  tearDown(() => db.close());

  testWidgets('チームレポートにチーム能力・ランキング・比較テーブルが表示される', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PerformanceAnalyticsApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('チーム分析'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('チームレポート（PDF出力）'));
    await tester.pumpAndSettle();

    expect(find.text('チームレポート'), findsWidgets);
    expect(find.text('チーム能力'), findsOneWidget);
    expect(find.text('AI分析'), findsOneWidget);
    expect(find.textContaining('総合ランキング'), findsOneWidget);
    expect(find.text('ポジション別比較（平均値）'), findsOneWidget);
    expect(find.text('年度別比較（平均値）'), findsOneWidget);
    expect(find.textContaining('横田向星'), findsWidgets);
  });
}
