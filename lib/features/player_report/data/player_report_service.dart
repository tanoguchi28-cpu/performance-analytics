import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/local_database.dart';
import '../../ai_insights/domain/athlete_insight.dart';
import '../../analytics/domain/statistics_calculator.dart';
import '../../athletes/data/local_athlete_repository.dart';
import '../../evaluation/data/ability_profile_service.dart';
import '../../evaluation/data/local_evaluation_criteria_repository.dart';
import '../../measurements/data/local_measurement_item_repository.dart';
import '../../measurements/data/local_measurement_repository.dart';
import '../../ranking/domain/ranking_calculator.dart';
import '../domain/player_report_models.dart';

part 'player_report_service.g.dart';

@riverpod
Future<PlayerReportData> playerReport(Ref ref, {required String athleteId}) async {
  final athleteRepo = ref.watch(athleteRepositoryProvider);
  final itemRepo = ref.watch(measurementItemRepositoryProvider);
  final measurementRepo = ref.watch(measurementRepositoryProvider);
  final criteriaRepo = ref.watch(evaluationCriteriaRepositoryProvider);

  final athlete = await athleteRepo.getById(athleteId);
  if (athlete == null) {
    throw StateError('選手が見つかりません');
  }

  final athletes = await athleteRepo.getAll();
  final items = await itemRepo.getAll();
  final sessions = await measurementRepo.getSessions();
  final latestSession = sessions.isEmpty ? null : sessions.first;

  final latestRecords = latestSession == null
      ? <MeasurementRecord>[]
      : await measurementRepo.getRecordsForSession(latestSession.id);
  final athleteHistory = await measurementRepo.getRecordsForAthlete(athleteId);

  final athleteLatestRecords = latestRecords.where((r) => r.athleteId == athleteId).toList();
  final abilityProfile = await computeAthleteAbilityProfile(
    items: items,
    criteriaRepo: criteriaRepo,
    athleteRecords: athleteLatestRecords,
    position: athlete.position,
  );
  final insight = generateAthleteInsight(abilityProfile);

  final overallRanking = RankingCalculator.computeOverallRanking(
    athletes: athletes,
    items: items,
    records: latestRecords,
  );
  final myOverallRanking = overallRanking.where((e) => e.athlete.id == athleteId).firstOrNull;

  // 測定日の古い順（1回目→2回目→…）に並んだ全履歴。前回比の算出に使う。
  final sessionDateById = {for (final s in sessions) s.id: s.measurementDate};
  final itemById = {for (final i in items) i.id: i};
  final historyByItemKey = <String, List<TrendPoint>>{};
  for (final record in athleteHistory) {
    final item = itemById[record.itemId];
    final date = sessionDateById[record.sessionId];
    if (item == null || date == null) continue;
    historyByItemKey
        .putIfAbsent(item.key, () => [])
        .add(TrendPoint(date: date, value: record.value));
  }

  final results = <PlayerResultRow>[];
  for (final item in items) {
    final myRecord = athleteLatestRecords.where((r) => r.itemId == item.id).firstOrNull;
    final itemRanking = RankingCalculator.computeItemRanking(
      athletes: athletes,
      item: item,
      records: latestRecords,
    );
    final myItemRank = itemRanking.where((e) => e.athlete.id == athleteId).firstOrNull;

    // 直近2回分の履歴から前回比を算出（1回目→2回目、2回目→3回目…と常に直近の変化を示す）。
    final history = historyByItemKey[item.key] ?? const <TrendPoint>[];
    final previousValue = history.length >= 2 ? history[history.length - 2].value : null;
    final percentChange = myRecord == null
        ? null
        : StatisticsCalculator.percentChange(
            from: previousValue,
            to: myRecord.value,
            higherIsBetter: item.higherIsBetter,
          );

    results.add(
      PlayerResultRow(
        item: item,
        latestValue: myRecord?.value,
        previousValue: previousValue,
        percentChange: percentChange,
        evaluationScore: myRecord == null
            ? null
            : await criteriaRepo.evaluate(
                itemKey: item.key,
                value: myRecord.value,
                position: athlete.position,
              ),
        rank: myItemRank?.rank,
        teamSize: itemRanking.isEmpty ? null : itemRanking.length,
      ),
    );
  }

  return PlayerReportData(
    athlete: athlete,
    abilityProfile: abilityProfile,
    insight: insight,
    overallRanking: myOverallRanking,
    overallRankingTeamSize: overallRanking.isEmpty ? null : overallRanking.length,
    results: results,
    historyByItemKey: historyByItemKey,
    latestSessionDate: latestSession?.measurementDate,
  );
}
