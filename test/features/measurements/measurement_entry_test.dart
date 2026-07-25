import 'package:drift/drift.dart';
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
          AthletesCompanion.insert(id: 'p1', name: '横田向星', grade: 2),
        );
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    // 14項目分の入力フォーム全体がデフォルトの800x600ビューポートでは収まらず
    // 「保存する」ボタンがensureVisible()を使っても画面外になることがあるため、
    // 縦に余裕を持たせたビューポートでスクロール絡みの不安定さを避ける。
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PerformanceAnalyticsApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'セッション作成→測定値入力→入力状況バッジが更新される',
    (tester) async {
      await pumpApp(tester);

      // 測定タブへ
      await tester.tap(find.text('測定'));
      await tester.pumpAndSettle();
      expect(find.text('測定データ'), findsOneWidget);
      expect(find.text('測定セッションがありません'), findsOneWidget);

      // セッション作成
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('測定セッションを作成'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'ラベル'),
        '2026年度 テスト測定',
      );
      await tester.tap(find.text('作成する'));
      await tester.pumpAndSettle();

      // セッション一覧に反映
      expect(find.text('測定データ'), findsOneWidget);
      expect(find.text('2026年度 テスト測定'), findsOneWidget);

      // セッション詳細へ
      await tester.tap(find.text('2026年度 テスト測定'));
      await tester.pumpAndSettle();
      expect(find.text('選手別入力状況'), findsOneWidget);
      expect(find.text('横田向星'), findsOneWidget);
      expect(find.text('0/14'), findsOneWidget);

      // 選手の入力画面へ
      await tester.tap(find.text('横田向星'));
      await tester.pumpAndSettle();
      expect(find.text('測定値入力'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, '身長'), '175');
      await tester.enterText(find.widgetWithText(TextFormField, '垂直跳び'), '68');
      await tester.ensureVisible(find.text('保存する'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存する'));
      await tester.pumpAndSettle();

      // セッション詳細で入力状況が更新されている
      expect(find.text('選手別入力状況'), findsOneWidget);
      expect(find.text('2/14'), findsOneWidget);

      // 誤入力した項目を空にして保存すると、その記録が削除される
      await tester.tap(find.text('横田向星'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, '身長'), '');
      await tester.ensureVisible(find.text('保存する'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存する'));
      await tester.pumpAndSettle();

      expect(find.text('選手別入力状況'), findsOneWidget);
      expect(find.text('1/14'), findsOneWidget);

      final records = await (db.select(db.measurementRecords)
            ..where((t) => t.athleteId.equals('p1') & t.itemId.equals('height')))
          .get();
      expect(records, isEmpty);
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );

  testWidgets(
    '測定セッションを削除すると、そのセッションの記録もまとめて消える',
    (tester) async {
      const sessionId = 's1';
      await db.into(db.measurementSessions).insert(
            MeasurementSessionsCompanion.insert(
              id: sessionId,
              measurementDate: DateTime(2026, 4, 1),
              label: const Value('誤ってインポートした測定'),
            ),
          );
      await db.into(db.measurementRecords).insert(
            MeasurementRecordsCompanion.insert(
              id: 'r1',
              athleteId: 'p1',
              sessionId: sessionId,
              itemId: 'vertical_jump',
              value: 50,
            ),
          );

      await pumpApp(tester);
      await tester.tap(find.text('測定'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('誤ってインポートした測定'));
      await tester.pumpAndSettle();
      expect(find.text('選手別入力状況'), findsOneWidget);

      await tester.tap(find.byTooltip('セッションを削除'));
      await tester.pumpAndSettle();
      expect(find.text('測定セッションを削除しますか？'), findsOneWidget);

      await tester.tap(find.text('削除する'));
      await tester.pumpAndSettle();

      // 一覧に戻り、削除したセッションが消えている
      expect(find.text('測定データ'), findsOneWidget);
      expect(find.text('誤ってインポートした測定'), findsNothing);

      final remainingSessions = await (db.select(db.measurementSessions)).get();
      expect(remainingSessions, isEmpty);
      final remainingRecords = await (db.select(db.measurementRecords)).get();
      expect(remainingRecords, isEmpty);
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );
}
