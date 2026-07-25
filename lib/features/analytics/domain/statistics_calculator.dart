import 'dart:math' as math;

/// 平均・中央値・標準偏差・偏差値・順位・変化率を算出する純粋関数群。
/// DBやFlutterに依存せず、呼び出し側が集めた数値リストに対して計算するだけの
/// ステートレスなロジック。UIへの組み込みは各画面のフェーズで行う。
class StatisticsCalculator {
  const StatisticsCalculator._();

  static double mean(List<double> values) {
    if (values.isEmpty) {
      throw ArgumentError('values must not be empty');
    }
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double median(List<double> values) {
    if (values.isEmpty) {
      throw ArgumentError('values must not be empty');
    }
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }

  /// 母集団標準偏差（チーム全体を母集団とみなす）。
  static double standardDeviation(List<double> values) {
    if (values.isEmpty) {
      throw ArgumentError('values must not be empty');
    }
    if (values.length == 1) return 0;
    final m = mean(values);
    final variance = values.map((v) => (v - m) * (v - m)).reduce((a, b) => a + b) / values.length;
    return math.sqrt(variance);
  }

  /// 偏差値。 `higherIsBetter=false`（タイム系など小さいほど良い項目）では
  /// 符号を反転し、値が小さいほど偏差値が高くなるようにする。
  /// 標準偏差が0（全員同値）の場合は50を返す。
  static double deviationScore({
    required double value,
    required double mean,
    required double standardDeviation,
    required bool higherIsBetter,
  }) {
    if (standardDeviation == 0) return 50;
    final diff = (value - mean) / standardDeviation;
    return 50 + 10 * (higherIsBetter ? diff : -diff);
  }

  /// 順位（1224方式）。同値は同順位、次の順位は人数分スキップする。
  /// `higherIsBetter=false`のときは値が小さいほど上位になる。
  static int competitiveRank({
    required List<double> values,
    required double value,
    required bool higherIsBetter,
  }) {
    if (values.isEmpty) {
      throw ArgumentError('values must not be empty');
    }
    final betterCount = values.where((v) {
      return higherIsBetter ? v > value : v < value;
    }).length;
    return betterCount + 1;
  }

  /// [from]から[to]への変化率(%)。正の値は「改善」を意味するように、
  /// `higherIsBetter=false`の項目は符号を反転する。
  /// [from]がnullまたは0の場合は算出不能としてnullを返す。
  static double? percentChange({
    required double? from,
    required double to,
    required bool higherIsBetter,
  }) {
    if (from == null || from == 0) return null;
    final rawRate = (to - from) / from.abs() * 100;
    return higherIsBetter ? rawRate : -rawRate;
  }
}
