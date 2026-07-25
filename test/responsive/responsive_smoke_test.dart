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

/// フェーズ15（仕上げ）: モバイル幅・デスクトップ幅の双方で主要画面が
/// RenderFlexオーバーフロー等のレイアウト崩れなく描画できることを確認する。
/// （オーバーフロー等のFlutterErrorはpump中に検出されテスト失敗として顕在化する）
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    app_main.teamSetupComplete = true;

    await db.into(db.athletes).insert(
          AthletesCompanion.insert(
            id: 'a1',
            name: '横田向星',
            grade: 1,
            position: const Value('G'),
            jerseyNumber: const Value(7),
          ),
        );
    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'a2', name: '小森瑛太', grade: 2, position: const Value('F')),
        );
    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'a3', name: '山田太郎', grade: 3, position: const Value('C')),
        );

    const session1 = 'session1';
    const session2 = 'session2';
    await db.into(db.measurementSessions).insert(
          MeasurementSessionsCompanion.insert(id: session1, measurementDate: DateTime(2025, 10, 1)),
        );
    await db.into(db.measurementSessions).insert(
          MeasurementSessionsCompanion.insert(id: session2, measurementDate: DateTime(2026, 4, 1)),
        );

    final records = [
      ('r1', 'a1', session1, 'vertical_jump', 62.0),
      ('r2', 'a2', session1, 'vertical_jump', 54.0),
      ('r3', 'a3', session1, 'vertical_jump', 48.0),
      ('r4', 'a1', session2, 'vertical_jump', 65.0),
      ('r5', 'a2', session2, 'vertical_jump', 55.0),
      ('r6', 'a3', session2, 'vertical_jump', 45.0),
      ('r7', 'a1', session2, 'three_quarter_sprint', 3.1),
      ('r8', 'a2', session2, 'three_quarter_sprint', 3.4),
      ('r9', 'a3', session2, 'three_quarter_sprint', 3.7),
    ];
    for (final (id, athleteId, sessionId, itemKey, value) in records) {
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

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
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

  const mobile = Size(375, 812);
  const desktop = Size(1400, 900);

  for (final size in [mobile, desktop]) {
    final label = size == mobile ? 'モバイル幅(375)' : 'デスクトップ幅(1400)';

    testWidgets('$label: 主要画面がオーバーフロー無く表示される', (tester) async {
      await pumpAt(tester, size);

      // ダッシュボード（起動直後）
      expect(find.text('ダッシュボード'), findsWidgets);

      // 選手一覧 → 選手詳細 → 選手ページ
      await tester.tap(find.text('選手'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('横田向星'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('選手ページを見る（推移・AI分析・PDF出力）'));
      await tester.tap(find.text('選手ページを見る（推移・AI分析・PDF出力）'));
      await tester.pumpAndSettle();
      expect(find.text('選手ページ'), findsOneWidget);

      // チーム分析 → チームレポート
      await tester.tap(find.text('チーム分析'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('チーム比較'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('チームレポート（PDF出力）'));
      await tester.pumpAndSettle();
      expect(find.text('チームレポート'), findsWidgets);

      // ランキング（項目別に切り替え）
      await tester.tap(find.text('ランキング'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('項目別順位'));
      await tester.pumpAndSettle();
      expect(find.text('測定項目'), findsOneWidget);

      // 測定 → Excelインポートウィザード
      await tester.tap(find.text('測定'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Excelから取り込み'));
      await tester.pumpAndSettle();
      expect(find.text('Excelインポート'), findsOneWidget);

      // 設定 → 測定項目管理・評価基準設定・チーム設定・バックアップ
      await tester.tap(find.text('設定'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('測定項目管理'));
      await tester.pumpAndSettle();
      expect(find.text('測定項目管理'), findsOneWidget);

      await tester.tap(find.byTooltip('項目を追加'));
      await tester.pumpAndSettle();
      expect(find.text('測定項目を追加'), findsOneWidget);
      // tester.pageBack()は「Back」という英語ツールチップを前提にしており、
      // 日本語ローカライズ後は戻るボタンのツールチップが「戻る」になるため使えない。
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('設定'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('評価基準設定'));
      await tester.pumpAndSettle();
      expect(find.text('評価基準設定'), findsOneWidget);

      await tester.tap(find.text('設定'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('データバックアップ'));
      await tester.pumpAndSettle();
      expect(find.text('エクスポートする'), findsOneWidget);
    });
  }
}
