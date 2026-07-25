import '../../../core/constants/ability_category.dart';

/// 1能力カテゴリの評価結果。[score]がnullなら「評価なし」
/// （そのカテゴリに属する測定項目が1つも測定・評価されていない）。
class AbilityScore {
  const AbilityScore({
    required this.category,
    required this.score,
    required this.contributingItemCount,
  });

  final AbilityCategory category;

  /// 該当カテゴリに属する測定項目の5段階評価の平均（小数のまま保持）。
  final double? score;

  /// 平均に寄与した（＝実際に評価できた）項目数。0なら[score]はnull。
  final int contributingItemCount;

  bool get hasData => score != null;

  /// 表示用に丸めた1〜5の整数評価。
  int? get roundedScore => score?.round();
}

/// 選手1名分の6能力カテゴリの評価プロファイル。
class AbilityProfile {
  const AbilityProfile(this.scores);

  final List<AbilityScore> scores;

  /// レーダーチャート等、実際にデータがあるカテゴリのみ。
  List<AbilityScore> get measuredScores => scores.where((s) => s.hasData).toList();

  /// [itemAbilityCategories]: 評価対象の測定項目ごとの能力カテゴリ（key=itemId）。
  ///   abilityCategory=noneの項目はここに含めないこと。
  /// [itemScores]: 各項目の5段階評価（key=itemId）。未測定/評価基準なしはnullまたはキー自体が無い。
  factory AbilityProfile.compute({
    required Map<String, AbilityCategory> itemAbilityCategories,
    required Map<String, int?> itemScores,
  }) {
    final byCategory = <AbilityCategory, List<int>>{
      for (final c in AbilityCategory.values)
        if (c != AbilityCategory.none) c: [],
    };

    itemAbilityCategories.forEach((itemId, category) {
      if (category == AbilityCategory.none) return;
      final score = itemScores[itemId];
      if (score == null) return;
      byCategory[category]!.add(score);
    });

    final scores = byCategory.entries.map((entry) {
      final values = entry.value;
      if (values.isEmpty) {
        return AbilityScore(category: entry.key, score: null, contributingItemCount: 0);
      }
      final avg = values.reduce((a, b) => a + b) / values.length;
      return AbilityScore(
        category: entry.key,
        score: avg,
        contributingItemCount: values.length,
      );
    }).toList();

    return AbilityProfile(scores);
  }

  /// 複数選手の[AbilityProfile]をカテゴリごとに平均し、チーム全体のプロファイルを作る。
  /// あるカテゴリで評価を持つ選手が1人もいなければそのカテゴリは「評価なし」のままになる。
  static AbilityProfile average(List<AbilityProfile> profiles) {
    final byCategory = <AbilityCategory, List<double>>{
      for (final c in AbilityCategory.values)
        if (c != AbilityCategory.none) c: [],
    };

    for (final profile in profiles) {
      for (final s in profile.scores) {
        if (s.score == null) continue;
        byCategory[s.category]!.add(s.score!);
      }
    }

    final scores = byCategory.entries.map((entry) {
      final values = entry.value;
      if (values.isEmpty) {
        return AbilityScore(category: entry.key, score: null, contributingItemCount: 0);
      }
      final avg = values.reduce((a, b) => a + b) / values.length;
      return AbilityScore(
        category: entry.key,
        score: avg,
        contributingItemCount: values.length,
      );
    }).toList();

    return AbilityProfile(scores);
  }
}
