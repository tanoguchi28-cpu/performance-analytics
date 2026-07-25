import '../../../core/constants/ability_category.dart';
import '../../evaluation/domain/ability_profile.dart';

/// カテゴリごとの推奨トレーニング（ルールベース）。
/// 将来的に外部AI（LLM等）へ差し替える場合もこのファイルのインターフェースは維持できる。
const _trainingSuggestions = <AbilityCategory, String>{
  AbilityCategory.explosivePower: 'ジャンプスクワットやプライオメトリクスなど、瞬発的なパワーを鍛えるトレーニングを取り入れましょう。',
  AbilityCategory.muscularPower: 'メディシンボール投げや上半身の補強運動で筋パワーの向上を図りましょう。',
  AbilityCategory.muscularEndurance: 'サーキットトレーニングや体幹トレーニングの頻度を増やしましょう。',
  AbilityCategory.cardioEndurance: 'インターバル走や持久走を継続的に取り入れ、全身持久力を高めましょう。',
  AbilityCategory.agility: 'ラダートレーニングや切り返し動作を含む反応系トレーニングを取り入れましょう。',
  AbilityCategory.flexibility: '練習前後のストレッチルーティンを習慣化し、可動域の改善に取り組みましょう。',
};

/// 選手1名分の強み・改善点・推奨トレーニング（ルールベースAI分析）。
class AthleteInsight {
  const AthleteInsight({
    required this.strengths,
    required this.weaknesses,
    required this.trainingSuggestions,
  });

  /// 評価が高いカテゴリ（強み）。
  final List<AbilityScore> strengths;

  /// 評価が低いカテゴリ（改善点）。
  final List<AbilityScore> weaknesses;

  /// [weaknesses]の各カテゴリに対応する推奨トレーニング文。
  final List<String> trainingSuggestions;

  bool get hasData => strengths.isNotEmpty || weaknesses.isNotEmpty;
}

/// 評価済みスコアがこの値以上なら「強み」とみなす。
const _strengthThreshold = 4;

/// 評価済みスコアがこの値以下なら「改善点」とみなす。
const _weaknessThreshold = 2;

/// [AbilityProfile]からルールベースで選手の強み・改善点・推奨トレーニングを生成する。
AthleteInsight generateAthleteInsight(AbilityProfile profile) {
  final measured = [...profile.measuredScores]
    ..sort((a, b) => b.score!.compareTo(a.score!));

  if (measured.isEmpty) {
    return const AthleteInsight(strengths: [], weaknesses: [], trainingSuggestions: []);
  }

  var strengths = measured.where((s) => s.roundedScore! >= _strengthThreshold).toList();
  var weaknesses = measured.where((s) => s.roundedScore! <= _weaknessThreshold).toList();

  // 全項目が中間評価などで該当が無い場合は、相対的に最高/最低を1件ずつ強み/改善点として示す。
  if (strengths.isEmpty) strengths = [measured.first];
  if (weaknesses.isEmpty && measured.length > 1) weaknesses = [measured.last];

  return AthleteInsight(
    strengths: strengths,
    weaknesses: weaknesses,
    trainingSuggestions: [
      for (final w in weaknesses)
        _trainingSuggestions[w.category] ?? '${w.category.label}を高めるトレーニングを取り入れましょう。',
    ],
  );
}
