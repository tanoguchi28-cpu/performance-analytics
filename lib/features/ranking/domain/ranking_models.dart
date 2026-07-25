import '../../../core/database/local_database.dart';

/// 総合順位1件。複数項目の偏差値平均で順位付けする。
class OverallRankingEntry {
  const OverallRankingEntry({
    required this.athlete,
    required this.averageDeviationScore,
    required this.itemCount,
    required this.rank,
  });

  final Athlete athlete;
  final double averageDeviationScore;

  /// 平均に使った測定項目数。
  final int itemCount;
  final int rank;
}

/// 測定項目1つでの順位1件。実測値そのもので順位付けする。
class ItemRankingEntry {
  const ItemRankingEntry({
    required this.athlete,
    required this.value,
    required this.rank,
  });

  final Athlete athlete;
  final double value;
  final int rank;
}
