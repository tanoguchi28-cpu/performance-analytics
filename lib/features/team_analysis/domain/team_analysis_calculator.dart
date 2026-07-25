import 'dart:math' as math;

import 'team_analysis_models.dart';

/// ヒストグラム・箱ひげ図・相関係数・年度区分を算出する純粋関数群。
/// [StatisticsCalculator]と同様、DBやFlutterに依存しないステートレスなロジック。
class TeamAnalysisCalculator {
  const TeamAnalysisCalculator._();

  /// [values]を[binCount]区間に等分してヒストグラムを作る。
  /// 全員が同値（幅0）の場合は1区間にまとめる。
  static List<HistogramBin> histogram(List<double> values, {int binCount = 6}) {
    if (values.isEmpty) return [];
    final min = values.reduce(math.min);
    final max = values.reduce(math.max);

    if (min == max) {
      return [HistogramBin(from: min, to: max, count: values.length)];
    }

    final width = (max - min) / binCount;
    final counts = List<int>.filled(binCount, 0);
    for (final v in values) {
      var index = ((v - min) / width).floor();
      if (index >= binCount) index = binCount - 1; // 最大値ちょうどは最終区間に含める
      if (index < 0) index = 0;
      counts[index]++;
    }

    return [
      for (var i = 0; i < binCount; i++)
        HistogramBin(from: min + width * i, to: min + width * (i + 1), count: counts[i]),
    ];
  }

  /// 五数要約（線形補間による四分位数）。
  static BoxPlotStats? boxPlot(List<double> values) {
    if (values.isEmpty) return null;
    final sorted = [...values]..sort();
    return BoxPlotStats(
      min: sorted.first,
      q1: _percentile(sorted, 0.25),
      median: _percentile(sorted, 0.5),
      q3: _percentile(sorted, 0.75),
      max: sorted.last,
    );
  }

  static double _percentile(List<double> sortedValues, double p) {
    if (sortedValues.length == 1) return sortedValues.first;
    final index = p * (sortedValues.length - 1);
    final lower = index.floor();
    final upper = index.ceil();
    if (lower == upper) return sortedValues[lower];
    final frac = index - lower;
    return sortedValues[lower] + (sortedValues[upper] - sortedValues[lower]) * frac;
  }

  /// ピアソン相関係数。[xs]と[ys]は同一選手の対応する値をこの順に渡すこと。
  /// 2ペア未満、またはどちらかの分散が0の場合は算出不能としてnullを返す。
  static double? pearsonCorrelation(List<double> xs, List<double> ys) {
    if (xs.length != ys.length || xs.length < 2) return null;

    final meanX = xs.reduce((a, b) => a + b) / xs.length;
    final meanY = ys.reduce((a, b) => a + b) / ys.length;

    var covariance = 0.0;
    var varX = 0.0;
    var varY = 0.0;
    for (var i = 0; i < xs.length; i++) {
      final dx = xs[i] - meanX;
      final dy = ys[i] - meanY;
      covariance += dx * dy;
      varX += dx * dx;
      varY += dy * dy;
    }

    if (varX == 0 || varY == 0) return null;
    return covariance / math.sqrt(varX * varY);
  }

  /// 学校年度（4月始まり）。1〜3月は前年の年度として扱う。
  static int academicYear(DateTime date) => date.month >= 4 ? date.year : date.year - 1;
}
