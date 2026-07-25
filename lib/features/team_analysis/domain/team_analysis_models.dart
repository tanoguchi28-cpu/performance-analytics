import '../../../core/database/local_database.dart';
import '../../evaluation/domain/ability_profile.dart';

/// ヒストグラムの1区間。
class HistogramBin {
  const HistogramBin({required this.from, required this.to, required this.count});

  final double from;
  final double to;
  final int count;

  String get rangeLabel => '${from.toStringAsFixed(1)}〜${to.toStringAsFixed(1)}';
}

/// 箱ひげ図に必要な五数要約（最小・第1四分位・中央値・第3四分位・最大）。
class BoxPlotStats {
  const BoxPlotStats({
    required this.min,
    required this.q1,
    required this.median,
    required this.q3,
    required this.max,
  });

  final double min;
  final double q1;
  final double median;
  final double q3;
  final double max;
}

/// 学年やポジションなど、グループ単位の箱ひげ図1件分。
class GroupBoxPlot {
  const GroupBoxPlot({required this.label, required this.stats, required this.count});

  final String label;
  final BoxPlotStats stats;
  final int count;
}

/// 散布図上の1選手分の点（X項目・Y項目それぞれの記録値）。
class AthletePoint {
  const AthletePoint({required this.athlete, required this.x, required this.y});

  final Athlete athlete;
  final double x;
  final double y;
}

/// 2測定項目間の相関係数（同一項目や算出不能な組み合わせはnull）。
class CorrelationMatrix {
  const CorrelationMatrix({required this.items, required this.values});

  final List<MeasurementItem> items;

  /// values[i][j] は items[i] と items[j] のピアソン相関係数。算出に十分なデータが無ければnull。
  final List<List<double?>> values;
}

/// 学年別・ポジション別などグループごとの平均値1件分。
class GroupAverage {
  const GroupAverage({required this.label, required this.average, required this.count});

  final String label;
  final double average;
  final int count;
}

/// 年度（4月始まり）ごとの平均値1件分。
class YearAverage {
  const YearAverage({required this.year, required this.average, required this.count});

  final int year;
  final double average;
  final int count;

  String get label => '$year年度';
}

/// 測定日に紐づけたレコード。年度別集計で使う。
class DatedRecord {
  const DatedRecord({required this.record, required this.measurementDate});

  final MeasurementRecord record;
  final DateTime measurementDate;
}

/// チーム分析画面が必要とするデータ一式。選択中のセッションを基準に算出する。
class TeamAnalysisData {
  const TeamAnalysisData({
    required this.athletes,
    required this.items,
    required this.sessions,
    required this.selectedSession,
    required this.selectedSessionRecords,
    required this.datedRecords,
    required this.abilityByPosition,
  });

  final List<Athlete> athletes;
  final List<MeasurementItem> items;

  /// 測定日降順。
  final List<MeasurementSession> sessions;
  final MeasurementSession? selectedSession;

  /// [selectedSession]における全選手の記録。
  final List<MeasurementRecord> selectedSessionRecords;

  /// 年度比較用に全セッションの記録を測定日付きで保持。
  final List<DatedRecord> datedRecords;

  /// ポジション（G/F/C）ごとの平均能力プロファイル。[selectedSession]基準。
  final Map<String, AbilityProfile> abilityByPosition;
}
