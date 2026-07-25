import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/core/constants/ability_category.dart';
import 'package:performance_analytics/features/evaluation/domain/ability_profile.dart';

void main() {
  group('AbilityProfile.compute', () {
    test('同じカテゴリの複数項目は平均される', () {
      final profile = AbilityProfile.compute(
        itemAbilityCategories: {
          'side_step': AbilityCategory.agility,
          'lane_agility': AbilityCategory.agility,
        },
        itemScores: {'side_step': 5, 'lane_agility': 3},
      );

      final agility = profile.scores.firstWhere((s) => s.category == AbilityCategory.agility);
      expect(agility.score, 4.0);
      expect(agility.contributingItemCount, 2);
      expect(agility.hasData, isTrue);
      expect(agility.roundedScore, 4);
    });

    test('未測定（評価スコアがnull）のカテゴリはhasData=falseになる', () {
      final profile = AbilityProfile.compute(
        itemAbilityCategories: {'vertical_jump': AbilityCategory.explosivePower},
        itemScores: {}, // 評価されていない
      );

      final explosive =
          profile.scores.firstWhere((s) => s.category == AbilityCategory.explosivePower);
      expect(explosive.hasData, isFalse);
      expect(explosive.score, isNull);
      expect(explosive.contributingItemCount, 0);
    });

    test('measuredScoresは評価済みカテゴリのみを含む', () {
      final profile = AbilityProfile.compute(
        itemAbilityCategories: {
          'vertical_jump': AbilityCategory.explosivePower,
          'sit_and_reach': AbilityCategory.flexibility,
        },
        itemScores: {'vertical_jump': 4}, // sit_and_reachは未測定
      );

      expect(profile.measuredScores.length, 1);
      expect(profile.measuredScores.single.category, AbilityCategory.explosivePower);
    });

    test('noneカテゴリの項目は評価対象から除外される（呼び出し規約）', () {
      final profile = AbilityProfile.compute(
        itemAbilityCategories: {'height': AbilityCategory.none},
        itemScores: {'height': 5},
      );

      expect(profile.scores.every((s) => s.category != AbilityCategory.none), isTrue);
      expect(profile.measuredScores, isEmpty);
    });

    test('全6カテゴリ（none以外）が常に含まれる', () {
      final profile = AbilityProfile.compute(itemAbilityCategories: {}, itemScores: {});
      expect(profile.scores.length, AbilityCategory.values.length - 1);
    });
  });
}
