import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/local_database.dart';
import '../../analytics/domain/statistics_calculator.dart';
import '../../athletes/data/local_athlete_repository.dart';
import '../../evaluation/data/ability_profile_service.dart';
import '../../evaluation/data/local_evaluation_criteria_repository.dart';
import '../../evaluation/domain/ability_profile.dart';
import '../../evaluation/domain/evaluation_criteria_repository.dart';
import '../../measurements/data/local_measurement_item_repository.dart';
import '../../measurements/data/local_measurement_repository.dart';
import '../../measurements/domain/measurement_repository.dart';
import '../domain/dashboard_models.dart';

part 'dashboard_data_service.g.dart';

/// ダッシュボードで種目別TOP5を出す対象項目（元仕様どおり）。
const _rankingItemKeys = ['vertical_jump', 'three_quarter_sprint', 'shuttle_run'];

/// 「大きく低下した」とみなす前回比の閾値(%)。これ以下ならアラート対象。
const _significantDeclineThreshold = -10.0;

const _completionTrendSessionLimit = 12;

@riverpod
Future<DashboardData> dashboardData(Ref ref) async {
  final athleteRepo = ref.watch(athleteRepositoryProvider);
  final itemRepo = ref.watch(measurementItemRepositoryProvider);
  final measurementRepo = ref.watch(measurementRepositoryProvider);
  final criteriaRepo = ref.watch(evaluationCriteriaRepositoryProvider);

  final athletes = await athleteRepo.getAll();
  final items = await itemRepo.getAll();
  final sessions = await measurementRepo.getSessions(); // 測定日降順

  final athleteById = {for (final a in athletes) a.id: a};
  final itemById = {for (final i in items) i.id: i};

  final latestSession = sessions.isEmpty ? null : sessions.first;
  final previousSession = sessions.length > 1 ? sessions[1] : null;

  final latestRecords = latestSession == null
      ? <MeasurementRecord>[]
      : await measurementRepo.getRecordsForSession(latestSession.id);
  final previousRecords = previousSession == null
      ? <MeasurementRecord>[]
      : await measurementRepo.getRecordsForSession(previousSession.id);

  final summary = _buildSummary(
    athletes: athletes,
    items: items,
    latestSession: latestSession,
    latestRecords: latestRecords,
  );

  final teamAbilityProfile = await _buildTeamAbilityProfile(
    athletes: athletes,
    items: items,
    latestRecords: latestRecords,
    criteriaRepo: criteriaRepo,
  );

  final rankings = _buildRankings(
    athleteById: athleteById,
    itemById: itemById,
    latestRecords: latestRecords,
    measurementDate: latestSession?.measurementDate,
  );

  final changes = _buildAthleteChanges(
    athletes: athletes,
    itemById: itemById,
    latestRecords: latestRecords,
    previousRecords: previousRecords,
  );
  final sortedByChangeDesc = [...changes]..sort((a, b) => b.avgPercentChange.compareTo(a.avgPercentChange));
  final topImproved = sortedByChangeDesc.take(10).toList();
  final topDeclined = sortedByChangeDesc.reversed.take(10).toList();
  final significantDeclines = sortedByChangeDesc
      .where((c) => c.avgPercentChange <= _significantDeclineThreshold)
      .toList()
    ..sort((a, b) => a.avgPercentChange.compareTo(b.avgPercentChange));

  final missingAthletes = latestSession == null
      ? <Athlete>[]
      : athletes.where((a) {
          final count = latestRecords.where((r) => r.athleteId == a.id).length;
          return count < items.length;
        }).toList();

  final completionTrend = await _buildCompletionTrend(
    sessions: sessions,
    athleteCount: athletes.length,
    itemCount: items.length,
    measurementRepo: measurementRepo,
  );

  return DashboardData(
    summary: summary,
    teamAbilityProfile: teamAbilityProfile,
    rankings: rankings,
    topImproved: topImproved,
    topDeclined: topDeclined,
    missingAthletes: missingAthletes,
    significantDeclines: significantDeclines,
    completionTrend: completionTrend,
    previousSessionDate: previousSession?.measurementDate,
  );
}

DashboardSummary _buildSummary({
  required List<Athlete> athletes,
  required List<MeasurementItem> items,
  required MeasurementSession? latestSession,
  required List<MeasurementRecord> latestRecords,
}) {
  final completionRate = (athletes.isEmpty || items.isEmpty)
      ? 0.0
      : (latestRecords.length / (athletes.length * items.length)).clamp(0.0, 1.0);

  double? averageForItemKey(String key) {
    final item = items.where((i) => i.key == key).firstOrNull;
    if (item == null) return null;
    final values = latestRecords.where((r) => r.itemId == item.id).map((r) => r.value).toList();
    if (values.isEmpty) return null;
    return StatisticsCalculator.mean(values);
  }

  return DashboardSummary(
    athleteCount: athletes.length,
    latestSessionDate: latestSession?.measurementDate,
    completionRate: completionRate,
    avgHeight: averageForItemKey('height'),
    avgWeight: averageForItemKey('weight'),
  );
}

Future<AbilityProfile> _buildTeamAbilityProfile({
  required List<Athlete> athletes,
  required List<MeasurementItem> items,
  required List<MeasurementRecord> latestRecords,
  required EvaluationCriteriaRepository criteriaRepo,
}) async {
  final profiles = await Future.wait(athletes.map((athlete) async {
    final athleteRecords = latestRecords.where((r) => r.athleteId == athlete.id).toList();
    if (athleteRecords.isEmpty) return null;
    return computeAthleteAbilityProfile(
      items: items,
      criteriaRepo: criteriaRepo,
      athleteRecords: athleteRecords,
      position: athlete.position,
    );
  }));
  return AbilityProfile.average(profiles.whereType<AbilityProfile>().toList());
}

List<RankingSection> _buildRankings({
  required Map<String, Athlete> athleteById,
  required Map<String, MeasurementItem> itemById,
  required List<MeasurementRecord> latestRecords,
  required DateTime? measurementDate,
}) {
  final itemByKey = {for (final i in itemById.values) i.key: i};
  final result = <RankingSection>[];

  for (final key in _rankingItemKeys) {
    final item = itemByKey[key];
    if (item == null) continue;

    final entries = latestRecords
        .where((r) => r.itemId == item.id)
        .map((r) => (athlete: athleteById[r.athleteId], value: r.value))
        .where((e) => e.athlete != null)
        .toList()
      ..sort((a, b) => item.higherIsBetter
          ? b.value.compareTo(a.value)
          : a.value.compareTo(b.value));

    result.add(
      RankingSection(
        itemKey: key,
        itemName: item.name,
        unit: item.unit,
        entries: [
          for (var i = 0; i < entries.length && i < 5; i++)
            RankedValue(athlete: entries[i].athlete!, value: entries[i].value, rank: i + 1),
        ],
        measurementDate: measurementDate,
      ),
    );
  }

  return result;
}

List<AthleteChange> _buildAthleteChanges({
  required List<Athlete> athletes,
  required Map<String, MeasurementItem> itemById,
  required List<MeasurementRecord> latestRecords,
  required List<MeasurementRecord> previousRecords,
}) {
  final previousByKey = {
    for (final r in previousRecords) (r.athleteId, r.itemId): r.value,
  };

  final changes = <AthleteChange>[];
  for (final athlete in athletes) {
    final rates = <double>[];
    for (final record in latestRecords.where((r) => r.athleteId == athlete.id)) {
      final item = itemById[record.itemId];
      if (item == null) continue;
      final previousValue = previousByKey[(athlete.id, record.itemId)];
      if (previousValue == null) continue;
      final rate = StatisticsCalculator.percentChange(
        from: previousValue,
        to: record.value,
        higherIsBetter: item.higherIsBetter,
      );
      if (rate != null) rates.add(rate);
    }
    if (rates.isEmpty) continue;
    changes.add(
      AthleteChange(
        athlete: athlete,
        avgPercentChange: StatisticsCalculator.mean(rates),
        itemCount: rates.length,
      ),
    );
  }
  return changes;
}

Future<List<CompletionTrendPoint>> _buildCompletionTrend({
  required List<MeasurementSession> sessions,
  required int athleteCount,
  required int itemCount,
  required MeasurementRepository measurementRepo,
}) async {
  if (sessions.isEmpty || athleteCount == 0 || itemCount == 0) return [];

  final recentSessions = sessions.take(_completionTrendSessionLimit).toList().reversed.toList();
  return Future.wait(recentSessions.map((session) async {
    final records = await measurementRepo.getRecordsForSession(session.id);
    return CompletionTrendPoint(
      sessionId: session.id,
      measurementDate: session.measurementDate,
      completionRate: (records.length / (athleteCount * itemCount)).clamp(0.0, 1.0),
    );
  }));
}
