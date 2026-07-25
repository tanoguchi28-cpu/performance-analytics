import 'statistics_calculator.dart';

/// ある測定項目について、ある選手の1測定値をチーム内で位置づけた統計結果。
/// DBには保存せず、その都度計算して画面表示に使う。
class StatisticsResult {
  const StatisticsResult({
    required this.mean,
    required this.median,
    required this.standardDeviation,
    required this.deviationScore,
    required this.rank,
    required this.participantCount,
    required this.bestRecord,
    required this.worstRecord,
    this.improvementRate,
    this.vsLastRate,
    this.vsLastYearRate,
  });

  final double mean;
  final double median;
  final double standardDeviation;

  /// 偏差値（higherIsBetter=falseの項目は値が小さいほど高くなるよう補正済み）。
  final double deviationScore;

  /// 順位（1224方式、同値は同順位）。
  final int rank;

  /// 順位計算の母数（チーム内でその項目を測定した人数）。
  final int participantCount;

  /// 自己ベスト（higherIsBetterに応じて最大/最小のいずれか）。
  final double bestRecord;

  /// 自己ワースト。
  final double worstRecord;

  /// 初回測定からの改善率(%)。履歴が無ければnull。
  final double? improvementRate;

  /// 前回測定からの変化率(%)。
  final double? vsLastRate;

  /// 前年同時期からの変化率(%)。
  final double? vsLastYearRate;

  /// [athleteValue]: 対象選手の今回の測定値。
  /// [teamValues]: 同一セッション内でその項目を測定した全選手の値（[athleteValue]を含む）。
  /// [historyValues]: 対象選手の過去の測定値（[athleteValue]は含めない、日付昇順）。
  /// [previousValue] / [lastYearValue]: 前回・前年同時期の値（呼び出し側が測定日から選んで渡す）。
  factory StatisticsResult.compute({
    required double athleteValue,
    required List<double> teamValues,
    required bool higherIsBetter,
    List<double> historyValues = const [],
    double? previousValue,
    double? lastYearValue,
  }) {
    final teamMean = StatisticsCalculator.mean(teamValues);
    final teamMedian = StatisticsCalculator.median(teamValues);
    final teamStdDev = StatisticsCalculator.standardDeviation(teamValues);
    final deviationScore = StatisticsCalculator.deviationScore(
      value: athleteValue,
      mean: teamMean,
      standardDeviation: teamStdDev,
      higherIsBetter: higherIsBetter,
    );
    final rank = StatisticsCalculator.competitiveRank(
      values: teamValues,
      value: athleteValue,
      higherIsBetter: higherIsBetter,
    );

    final allHistory = [...historyValues, athleteValue];
    final firstValue = historyValues.isEmpty ? null : historyValues.first;

    double best = allHistory.first;
    double worst = allHistory.first;
    for (final v in allHistory.skip(1)) {
      final betterThanBest = higherIsBetter ? v > best : v < best;
      final worseThanWorst = higherIsBetter ? v < worst : v > worst;
      if (betterThanBest) best = v;
      if (worseThanWorst) worst = v;
    }

    return StatisticsResult(
      mean: teamMean,
      median: teamMedian,
      standardDeviation: teamStdDev,
      deviationScore: deviationScore,
      rank: rank,
      participantCount: teamValues.length,
      bestRecord: best,
      worstRecord: worst,
      improvementRate: StatisticsCalculator.percentChange(
        from: firstValue,
        to: athleteValue,
        higherIsBetter: higherIsBetter,
      ),
      vsLastRate: StatisticsCalculator.percentChange(
        from: previousValue,
        to: athleteValue,
        higherIsBetter: higherIsBetter,
      ),
      vsLastYearRate: StatisticsCalculator.percentChange(
        from: lastYearValue,
        to: athleteValue,
        higherIsBetter: higherIsBetter,
      ),
    );
  }
}
