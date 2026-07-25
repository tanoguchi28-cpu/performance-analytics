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
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PerformanceAnalyticsApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();
  }

  testWidgets('設定ハブから各画面に遷移できる', (tester) async {
    await pumpApp(tester);

    expect(find.text('測定項目管理'), findsOneWidget);
    expect(find.text('評価基準設定'), findsOneWidget);
    expect(find.text('チーム設定'), findsOneWidget);
    expect(find.text('データバックアップ'), findsOneWidget);
  });

  testWidgets('測定項目を新規追加すると一覧に反映される', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('測定項目管理'));
    await tester.pumpAndSettle();
    expect(find.text('身長'), findsOneWidget);

    await tester.tap(find.byTooltip('項目を追加'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, '項目キー *'), 'grip_strength');
    await tester.enterText(find.widgetWithText(TextFormField, '項目名 *'), '握力');
    await tester.enterText(find.widgetWithText(TextFormField, '単位 *'), 'kg');
    await tester.ensureVisible(find.text('追加する'));
    await tester.tap(find.text('追加する'));
    await tester.pumpAndSettle();

    expect(find.text('握力'), findsOneWidget);
  });

  testWidgets('評価基準の得点帯を編集して保存できる', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('評価基準設定'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('垂直跳び').last);
    await tester.pumpAndSettle();

    expect(find.text('G'), findsWidgets);
    expect(find.text('評価5'), findsWidgets);

    final minField = find.widgetWithText(TextField, '下限（空欄=制限なし）').first;
    await tester.ensureVisible(minField);
    await tester.enterText(minField, '99');
    await tester.ensureVisible(find.text('保存する').first);
    await tester.tap(find.text('保存する').first);
    await tester.pumpAndSettle();

    expect(find.text('保存しました'), findsOneWidget);
  });

  testWidgets('チーム名を編集して保存できる', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('チーム設定'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'チーム名 *'), '富山第一高校');
    await tester.tap(find.text('保存する'));
    await tester.pumpAndSettle();

    expect(find.text('保存しました'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('team_name'), '富山第一高校');
  });

  testWidgets('データバックアップ画面にエクスポート/インポートの導線が表示される', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('データバックアップ'));
    await tester.pumpAndSettle();

    expect(find.text('エクスポートする'), findsOneWidget);
    expect(find.text('インポートする'), findsOneWidget);
  });
}
