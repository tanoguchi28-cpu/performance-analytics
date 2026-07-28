import '../../../core/database/local_database.dart';
import '../../evaluation/domain/ability_profile.dart';

/// ある測定項目でのランキング1エントリ（ダッシュボードのTOP5表示用の簡易版）。
class RankedValue {
  const RankedValue({required this.athlete, required this.value, required this.rank});

  final Athlete athlete;
  final double value;
  final int rank;
}

/// 1測定項目のTOP5ランキング（項目名・単位付き、ダッシュボード表示用）。
class RankingSection {
  const RankingSection({
    required this.itemKey,
    required this.itemName,
    required this.unit,
    required this.entries,
    this.measurementDate,
  });

  final String itemKey;
  final String itemName;
  final String unit;
  final List<RankedValue> entries;

  /// このランキングの算出に使った測定日（最新セッション基準）。
  final DateTime? measurementDate;
}

/// 前回セッションとの比較による選手ごとの変化量（改善ランキング・アラート用）。
class AthleteChange {
  const AthleteChange({
    required this.athlete,
    required this.avgPercentChange,
    required this.itemCount,
  });

  final Athlete athlete;

  /// 前回値がある項目群での変化率(%)の平均。正の値ほど改善。
  final double avgPercentChange;

  /// 平均に使った項目数。
  final int itemCount;
}

/// 測定実施率の推移1点（1セッション分）。
class CompletionTrendPoint {
  const CompletionTrendPoint({
    required this.sessionId,
    required this.measurementDate,
    required this.completionRate,
  });

  final String sessionId;
  final DateTime measurementDate;

  /// 0.0〜1.0。
  final double completionRate;
}

class DashboardSummary {
  const DashboardSummary({
    required this.athleteCount,
    required this.latestSessionDate,
    required this.completionRate,
    required this.avgHeight,
    required this.avgWeight,
  });

  final int athleteCount;
  final DateTime? latestSessionDate;

  /// 最新セッションでの測定実施率（0.0〜1.0）。
  final double completionRate;
  final double? avgHeight;
  final double? avgWeight;
}

/// ダッシュボード表示に必要な情報一式。最新セッションを基準に算出する。
class DashboardData {
  const DashboardData({
    required this.summary,
    required this.teamAbilityProfile,
    required this.rankings,
    required this.topImproved,
    required this.topDeclined,
    required this.missingAthletes,
    required this.significantDeclines,
    required this.completionTrend,
    required this.sessions,
    this.previousSessionDate,
  });

  final DashboardSummary summary;
  final AbilityProfile teamAbilityProfile;

  /// 測定セッション一覧（測定日降順）。「チーム能力」カードのセッション選択に使う。
  final List<MeasurementSession> sessions;

  final List<RankingSection> rankings;

  /// 前回比向上TOP10（降順）。
  final List<AthleteChange> topImproved;

  /// 前回比低下TOP10（改善率が低い順）。
  final List<AthleteChange> topDeclined;

  /// 前回比の比較元セッションの測定日（無ければnull）。比較先は
  /// [summary.latestSessionDate]。
  final DateTime? previousSessionDate;

  /// 最新セッションで測定漏れがある選手。
  final List<Athlete> missingAthletes;

  /// 前回から大きく低下した選手（アラート閾値超え）。
  final List<AthleteChange> significantDeclines;

  final List<CompletionTrendPoint> completionTrend;
}
