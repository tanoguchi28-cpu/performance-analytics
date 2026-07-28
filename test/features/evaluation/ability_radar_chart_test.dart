import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/core/constants/ability_category.dart';
import 'package:performance_analytics/features/evaluation/domain/ability_profile.dart';
import 'package:performance_analytics/shared/widgets/ability_radar_chart.dart';

void main() {
  Future<void> pump(WidgetTester tester, AbilityProfile profile) {
    return tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AbilityRadarChart(profile: profile))),
    );
  }

  testWidgets('評価データが無い場合は案内メッセージを表示する', (tester) async {
    await pump(tester, const AbilityProfile([]));

    expect(find.text('測定データがありません'), findsOneWidget);
    expect(find.byType(RadarChart), findsNothing);
  });

  testWidgets('評価済みが1項目でも6軸全て（未測定は0扱い）でレーダーチャートを描画する', (tester) async {
    // 実際のAbilityProfile.compute()/averageと同様、noneを除く全6カテゴリ分の
    // エントリを持つ（1つだけ評価あり、残り5つはscore:nullで「未測定」）。
    final profile = AbilityProfile([
      const AbilityScore(
        category: AbilityCategory.explosivePower,
        score: 4,
        contributingItemCount: 1,
      ),
      for (final c in AbilityCategory.values)
        if (c != AbilityCategory.none && c != AbilityCategory.explosivePower)
          AbilityScore(category: c, score: null, contributingItemCount: 0),
    ]);

    await pump(tester, profile);

    // fl_chartの軸タイトルはCustomPainterでキャンバスに直接描画されるため、
    // 通常のWidgetテスターでは文字列の中身までは検証できない（実機で目視確認する）。
    expect(find.byType(RadarChart), findsOneWidget);
  });

  testWidgets('評価済みが3項目以上ならレーダーチャートを描画する', (tester) async {
    final profile = AbilityProfile([
      const AbilityScore(
        category: AbilityCategory.explosivePower,
        score: 4,
        contributingItemCount: 1,
      ),
      const AbilityScore(
        category: AbilityCategory.flexibility,
        score: 3,
        contributingItemCount: 1,
      ),
      const AbilityScore(
        category: AbilityCategory.agility,
        score: 5,
        contributingItemCount: 2,
      ),
    ]);

    await pump(tester, profile);

    expect(find.byType(RadarChart), findsOneWidget);
  });
}
