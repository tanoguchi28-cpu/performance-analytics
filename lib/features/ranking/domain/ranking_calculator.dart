import '../../../core/database/local_database.dart';
import '../../analytics/domain/statistics_calculator.dart';
import 'ranking_models.dart';

/// 総合順位・項目別順位を算出する純粋関数群。
/// [athletes]・[records]は呼び出し側が学年・ポジション等で既に絞り込んだ
/// 「比較対象の母集団」を渡す想定（同じ母集団内で偏差値・順位を計算するため）。
class RankingCalculator {
  const RankingCalculator._();

  /// 各測定項目の偏差値を算出し、選手ごとに平均したものを「総合スコア」として順位付けする。
  /// 偏差値は項目間の単位差を吸収するため、cm/sec/回など異なる単位の項目を
  /// 公平に合算できる。
  static List<OverallRankingEntry> computeOverallRanking({
    required List<Athlete> athletes,
    required List<MeasurementItem> items,
    required List<MeasurementRecord> records,
  }) {
    final itemById = {for (final i in items) i.id: i};
    final recordsByItem = <String, List<MeasurementRecord>>{};
    for (final r in records) {
      if (!itemById.containsKey(r.itemId)) continue;
      recordsByItem.putIfAbsent(r.itemId, () => []).add(r);
    }

    final deviationByAthleteItem = <(String athleteId, String itemId), double>{};
    recordsByItem.forEach((itemId, itemRecords) {
      final item = itemById[itemId]!;
      final values = itemRecords.map((r) => r.value).toList();
      final mean = StatisticsCalculator.mean(values);
      final stddev = StatisticsCalculator.standardDeviation(values);
      for (final r in itemRecords) {
        deviationByAthleteItem[(r.athleteId, itemId)] = StatisticsCalculator.deviationScore(
          value: r.value,
          mean: mean,
          standardDeviation: stddev,
          higherIsBetter: item.higherIsBetter,
        );
      }
    });

    final unranked = <({Athlete athlete, double avg, int count})>[];
    for (final athlete in athletes) {
      final scores = [
        for (final item in items) ?deviationByAthleteItem[(athlete.id, item.id)],
      ];
      if (scores.isEmpty) continue;
      unranked.add((athlete: athlete, avg: StatisticsCalculator.mean(scores), count: scores.length));
    }

    unranked.sort((a, b) => b.avg.compareTo(a.avg));
    final allAverages = unranked.map((e) => e.avg).toList();

    return [
      for (final e in unranked)
        OverallRankingEntry(
          athlete: e.athlete,
          averageDeviationScore: e.avg,
          itemCount: e.count,
          rank: StatisticsCalculator.competitiveRank(
            values: allAverages,
            value: e.avg,
            higherIsBetter: true,
          ),
        ),
    ];
  }

  /// 1測定項目について、実測値そのもので順位付けする。
  static List<ItemRankingEntry> computeItemRanking({
    required List<Athlete> athletes,
    required MeasurementItem item,
    required List<MeasurementRecord> records,
  }) {
    final athleteById = {for (final a in athletes) a.id: a};

    final unranked = records
        .where((r) => r.itemId == item.id && athleteById.containsKey(r.athleteId))
        .map((r) => (athlete: athleteById[r.athleteId]!, value: r.value))
        .toList()
      ..sort((a, b) =>
          item.higherIsBetter ? b.value.compareTo(a.value) : a.value.compareTo(b.value));

    final allValues = unranked.map((e) => e.value).toList();

    return [
      for (final e in unranked)
        ItemRankingEntry(
          athlete: e.athlete,
          value: e.value,
          rank: StatisticsCalculator.competitiveRank(
            values: allValues,
            value: e.value,
            higherIsBetter: item.higherIsBetter,
          ),
        ),
    ];
  }
}
