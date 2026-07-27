import '../../../core/database/local_database.dart';
import '../../ai_insights/domain/athlete_insight.dart';
import '../../evaluation/domain/ability_profile.dart';
import '../../ranking/domain/ranking_models.dart';

/// 選手個人ページの測定結果一覧1行分。
class PlayerResultRow {
  const PlayerResultRow({
    required this.item,
    required this.latestValue,
    required this.previousValue,
    required this.percentChange,
    required this.evaluationScore,
    required this.rank,
    required this.teamSize,
  });

  final MeasurementItem item;
  final double? latestValue;

  /// 前回（1つ前の測定日）の記録。2回分以上の履歴がなければnull。
  final double? previousValue;

  /// 前回からの変化率(%)。higherIsBetter=falseの項目は数値が小さくなった方が
  /// プラスになるよう符号調整済み（[StatisticsCalculator.percentChange]参照）。
  final double? percentChange;

  /// 5段階評価。評価基準が無い/未測定ならnull。
  final int? evaluationScore;

  /// チーム内順位。未測定ならnull。
  final int? rank;

  /// 順位算出の母数（その項目を測定した人数）。
  final int? teamSize;
}

/// 選手個人ページの推移グラフ1点。
class TrendPoint {
  const TrendPoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}

/// 選手個人ページの表示に必要な情報一式。
class PlayerReportData {
  const PlayerReportData({
    required this.athlete,
    required this.abilityProfile,
    required this.insight,
    required this.overallRanking,
    required this.overallRankingTeamSize,
    required this.results,
    required this.historyByItemKey,
    this.latestSessionDate,
  });

  final Athlete athlete;
  final AbilityProfile abilityProfile;
  final AthleteInsight insight;

  /// チーム内の総合順位。1項目も測定していなければnull。
  final OverallRankingEntry? overallRanking;
  final int? overallRankingTeamSize;

  final List<PlayerResultRow> results;

  /// key = MeasurementItem.key。日付昇順。
  final Map<String, List<TrendPoint>> historyByItemKey;

  /// [results]の「記録」列が基づく最新セッションの測定日。
  final DateTime? latestSessionDate;
}
