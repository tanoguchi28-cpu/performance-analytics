import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/local_database.dart';
import '../../athletes/data/local_athlete_repository.dart';
import '../../evaluation/data/ability_profile_service.dart';
import '../../evaluation/data/local_evaluation_criteria_repository.dart';
import '../../evaluation/domain/ability_profile.dart';
import '../../evaluation/domain/evaluation_criteria_repository.dart';
import '../../measurements/data/local_measurement_item_repository.dart';
import '../../measurements/data/local_measurement_repository.dart';
import '../../ranking/domain/ranking_calculator.dart';
import '../../team_analysis/data/team_analysis_service.dart' show buildDatedRecords;
import '../../team_analysis/domain/team_analysis_calculator.dart';
import '../../team_analysis/domain/team_analysis_models.dart';
import '../domain/team_report_models.dart';

part 'team_report_service.g.dart';

/// 項目別ランキングでPDF/画面に表示する上位件数。
const _itemRankingTopN = 3;

const _positionColumns = ['G', 'F', 'C'];

@riverpod
Future<TeamReportData> teamReport(Ref ref) async {
  final athleteRepo = ref.watch(athleteRepositoryProvider);
  final itemRepo = ref.watch(measurementItemRepositoryProvider);
  final measurementRepo = ref.watch(measurementRepositoryProvider);
  final criteriaRepo = ref.watch(evaluationCriteriaRepositoryProvider);

  final athletes = await athleteRepo.getAll();
  final items = await itemRepo.getAll();
  final sessions = await measurementRepo.getSessions(); // 測定日降順
  final session = sessions.isEmpty ? null : sessions.first;

  final records = session == null
      ? <MeasurementRecord>[]
      : await measurementRepo.getRecordsForSession(session.id);
  final athleteById = {for (final a in athletes) a.id: a};

  final teamAbilityProfile = await _buildTeamAbilityProfile(
    athletes: athletes,
    items: items,
    records: records,
    criteriaRepo: criteriaRepo,
  );

  final overallRanking = RankingCalculator.computeOverallRanking(
    athletes: athletes,
    items: items,
    records: records,
  );

  final itemRankingsByItemId = {
    for (final item in items)
      item.id: RankingCalculator.computeItemRanking(athletes: athletes, item: item, records: records)
          .take(_itemRankingTopN)
          .toList(),
  };

  final positionComparison = _comparisonTable(
    items: items,
    records: records,
    athleteById: athleteById,
    groupKey: (a) => a.position,
    columns: _positionColumns,
  );

  final datedRecords = await buildDatedRecords(sessions: sessions, measurementRepo: measurementRepo);
  final yearComparison = _yearComparisonTable(items: items, datedRecords: datedRecords);

  return TeamReportData(
    session: session,
    athleteCount: athletes.length,
    teamAbilityProfile: teamAbilityProfile,
    overallRanking: overallRanking,
    itemRankingsByItemId: itemRankingsByItemId,
    items: items,
    positionComparison: positionComparison,
    yearComparison: yearComparison,
  );
}

Future<AbilityProfile> _buildTeamAbilityProfile({
  required List<Athlete> athletes,
  required List<MeasurementItem> items,
  required List<MeasurementRecord> records,
  required EvaluationCriteriaRepository criteriaRepo,
}) async {
  final profiles = <AbilityProfile>[];
  for (final athlete in athletes) {
    final athleteRecords = records.where((r) => r.athleteId == athlete.id).toList();
    if (athleteRecords.isEmpty) continue;
    profiles.add(
      await computeAthleteAbilityProfile(
        items: items,
        criteriaRepo: criteriaRepo,
        athleteRecords: athleteRecords,
        position: athlete.position,
      ),
    );
  }
  return AbilityProfile.average(profiles);
}

ComparisonTable _comparisonTable({
  required List<MeasurementItem> items,
  required List<MeasurementRecord> records,
  required Map<String, Athlete> athleteById,
  required String? Function(Athlete) groupKey,
  required List<String> columns,
}) {
  final rows = <ComparisonRow>[];
  for (final item in items) {
    final valuesByGroup = <String, List<double>>{};
    for (final record in records.where((r) => r.itemId == item.id)) {
      final athlete = athleteById[record.athleteId];
      if (athlete == null) continue;
      final key = groupKey(athlete);
      if (key == null) continue;
      valuesByGroup.putIfAbsent(key, () => []).add(record.value);
    }
    if (valuesByGroup.isEmpty) continue;

    rows.add(
      ComparisonRow(
        item: item,
        values: [
          for (final col in columns)
            valuesByGroup[col] == null
                ? null
                : valuesByGroup[col]!.reduce((a, b) => a + b) / valuesByGroup[col]!.length,
        ],
      ),
    );
  }
  return ComparisonTable(columnLabels: columns, rows: rows);
}

ComparisonTable _yearComparisonTable({
  required List<MeasurementItem> items,
  required List<DatedRecord> datedRecords,
}) {
  final years = datedRecords.map((d) => TeamAnalysisCalculator.academicYear(d.measurementDate)).toSet().toList()
    ..sort();
  final columns = [for (final y in years) '$y年度'];

  final rows = <ComparisonRow>[];
  for (final item in items) {
    final valuesByYear = <int, List<double>>{};
    for (final d in datedRecords.where((d) => d.record.itemId == item.id)) {
      final year = TeamAnalysisCalculator.academicYear(d.measurementDate);
      valuesByYear.putIfAbsent(year, () => []).add(d.record.value);
    }
    if (valuesByYear.isEmpty) continue;

    rows.add(
      ComparisonRow(
        item: item,
        values: [
          for (final y in years)
            valuesByYear[y] == null
                ? null
                : valuesByYear[y]!.reduce((a, b) => a + b) / valuesByYear[y]!.length,
        ],
      ),
    );
  }
  return ComparisonTable(columnLabels: columns, rows: rows);
}
