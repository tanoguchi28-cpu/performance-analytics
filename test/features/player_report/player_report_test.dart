import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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
          AthletesCompanion.insert(id: 'a1', name: '横田向星', grade: 2, position: const Value('G')),
        );
    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'a2', name: '小森瑛太', grade: 2, position: const Value('F')),
        );

    // 2回分のセッションで垂直跳びを記録し、推移グラフの対象データを作る
    const session1 = 'session1';
    const session2 = 'session2';
    await db.into(db.measurementSessions).insert(
          MeasurementSessionsCompanion.insert(id: session1, measurementDate: DateTime(2026, 4, 1)),
        );
    await db.into(db.measurementSessions).insert(
          MeasurementSessionsCompanion.insert(id: session2, measurementDate: DateTime(2026, 6, 1)),
        );

    await db.into(db.measurementRecords).insert(
          MeasurementRecordsCompanion.insert(
            id: 'r1',
            athleteId: 'a1',
            sessionId: session1,
            itemId: 'vertical_jump',
            value: 60,
          ),
        );
    await db.into(db.measurementRecords).insert(
          MeasurementRecordsCompanion.insert(
            id: 'r2',
            athleteId: 'a1',
            sessionId: session2,
            itemId: 'vertical_jump',
            value: 65,
          ),
        );
    await db.into(db.measurementRecords).insert(
          MeasurementRecordsCompanion.insert(
            id: 'r3',
            athleteId: 'a2',
            sessionId: session2,
            itemId: 'vertical_jump',
            value: 50,
          ),
        );
  });

  tearDown(() => db.close());

  testWidgets('選手ページに測定結果・推移グラフ・AI分析・コーチコメントが表示される', (tester) async {
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

    await tester.ensureVisible(find.text('選手ページを見る（推移・AI分析・PDF出力）'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('選手ページを見る（推移・AI分析・PDF出力）'));
    await tester.pumpAndSettle();

    expect(find.text('選手ページ'), findsOneWidget);
    expect(find.text('測定結果一覧'), findsOneWidget);
    expect(find.text('推移グラフ'), findsOneWidget);
    expect(find.text('AI分析'), findsOneWidget);
    expect(find.text('コーチコメント'), findsOneWidget);
    expect(find.textContaining('総合順位'), findsWidgets);

    // コーチコメントを入力して保存
    await tester.enterText(find.byType(TextField), 'よく頑張っています。');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('保存する'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存する'));
    await tester.pumpAndSettle();

    final saved = await (db.select(db.athletes)..where((t) => t.id.equals('a1'))).getSingle();
    expect(saved.coachComment, 'よく頑張っています。');
  });
}
