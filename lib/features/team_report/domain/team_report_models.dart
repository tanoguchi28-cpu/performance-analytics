import '../../../core/database/local_database.dart';
import '../../evaluation/domain/ability_profile.dart';
import '../../ranking/domain/ranking_models.dart';

/// ポジション別・年度別など、項目×グループの平均値比較テーブルの1行。
/// [values]は[ComparisonTable.columnLabels]と同じ順序・同じ長さ。データが無いグループはnull。
class ComparisonRow {
  const ComparisonRow({required this.item, required this.values});

  final MeasurementItem item;
  final List<double?> values;
}

/// 項目×グループの平均値比較テーブル。ポジション別・年度別のいずれにも使う汎用形式。
class ComparisonTable {
  const ComparisonTable({required this.columnLabels, required this.rows});

  final List<String> columnLabels;
  final List<ComparisonRow> rows;

  bool get isEmpty => columnLabels.isEmpty || rows.isEmpty;
}

/// チームレポート（A4印刷/PDF出力）に必要なデータ一式。最新セッションを基準に算出する。
class TeamReportData {
  const TeamReportData({
    required this.session,
    required this.athleteCount,
    required this.teamAbilityProfile,
    required this.overallRanking,
    required this.itemRankingsByItemId,
    required this.items,
    required this.positionComparison,
    required this.yearComparison,
  });

  final MeasurementSession? session;
  final int athleteCount;
  final AbilityProfile teamAbilityProfile;

  /// 全選手分の総合順位（表示側で上位N件に絞る）。
  final List<OverallRankingEntry> overallRanking;

  /// 測定項目ID -> その項目の上位ランキング（呼び出し側で件数を絞り込み済み）。
  final Map<String, List<ItemRankingEntry>> itemRankingsByItemId;
  final List<MeasurementItem> items;

  final ComparisonTable positionComparison;
  final ComparisonTable yearComparison;
}
