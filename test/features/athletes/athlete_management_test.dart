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

  setUp(() {
    // ThemeMode_プロバイダ等が使うSharedPreferencesをテスト環境用にモック化
    // (未設定だとプラットフォームチャンネル呼び出しがハングし続ける)。
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    app_main.teamSetupComplete = true; // オンボーディングをスキップ
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
  }

  testWidgets('選手を新規登録すると一覧・詳細に反映される', (tester) async {
    await pumpApp(tester);

    // ダッシュボードからナビゲーションで選手一覧へ
    await tester.tap(find.text('選手'));
    await tester.pumpAndSettle();
    expect(find.text('選手一覧'), findsOneWidget);
    expect(find.text('該当する選手がいません'), findsOneWidget);

    // 選手登録画面へ
    await tester.tap(find.byIcon(Icons.person_add_outlined));
    await tester.pumpAndSettle();
    expect(find.text('選手を登録'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, '氏名 *'), '横田向星');

    // ポジションドロップダウン: Gを選択
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('G').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('登録する'));
    await tester.pumpAndSettle();

    // 一覧に反映されている（ポジションのラベルは絞り込みチップと重複するのでfindsWidgets）
    expect(find.text('選手一覧'), findsOneWidget);
    expect(find.text('横田向星'), findsOneWidget);
    expect(find.text('G'), findsWidgets);

    // 詳細画面へ遷移して内容を確認
    await tester.tap(find.text('横田向星'));
    await tester.pumpAndSettle();
    expect(find.text('選手プロフィール'), findsOneWidget);
    expect(find.text('横田向星'), findsOneWidget);
  });

  testWidgets('ポジションで絞り込みできる', (tester) async {
    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'p1', name: '選手A', grade: 2, position: const Value('G')),
        );
    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'p2', name: '選手B', grade: 3, position: const Value('C')),
        );

    await pumpApp(tester);
    await tester.tap(find.text('選手'));
    await tester.pumpAndSettle();

    expect(find.text('選手A'), findsOneWidget);
    expect(find.text('選手B'), findsOneWidget);

    // ポジションフィルタ「C」を選択 → 選手Aが消える
    await tester.tap(find.widgetWithText(ChoiceChip, 'C'));
    await tester.pumpAndSettle();

    expect(find.text('選手A'), findsNothing);
    expect(find.text('選手B'), findsOneWidget);
  });

  testWidgets('選手を削除すると測定記録も含めて消え、一覧から消える', (tester) async {
    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'p1', name: '誤登録太郎', grade: 1, position: const Value('G')),
        );
    await db.into(db.measurementSessions).insert(
          MeasurementSessionsCompanion.insert(id: 's1', measurementDate: DateTime(2026, 4, 1)),
        );
    await db.into(db.measurementRecords).insert(
          MeasurementRecordsCompanion.insert(
            id: 'r1',
            athleteId: 'p1',
            sessionId: 's1',
            itemId: 'vertical_jump',
            value: 50,
          ),
        );

    await pumpApp(tester);
    await tester.tap(find.text('選手'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('誤登録太郎'));
    await tester.pumpAndSettle();
    expect(find.text('選手プロフィール'), findsOneWidget);

    await tester.tap(find.byTooltip('削除'));
    await tester.pumpAndSettle();
    expect(find.text('選手を削除しますか？'), findsOneWidget);

    await tester.tap(find.text('削除する'));
    await tester.pumpAndSettle();

    // 一覧に戻り、削除した選手が消えている
    expect(find.text('選手一覧'), findsOneWidget);
    expect(find.text('誤登録太郎'), findsNothing);

    final remainingAthletes = await (db.select(db.athletes)).get();
    expect(remainingAthletes, isEmpty);
    final remainingRecords = await (db.select(db.measurementRecords)).get();
    expect(remainingRecords, isEmpty);
  });
}
