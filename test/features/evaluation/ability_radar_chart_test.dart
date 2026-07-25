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

  testWidgets('評価済みが2項目以下の場合はチャートを描画せず案内を出す', (tester) async {
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
    ]);

    await pump(tester, profile);

    expect(find.textContaining('3項目以上'), findsOneWidget);
    expect(find.byType(RadarChart), findsNothing);
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
