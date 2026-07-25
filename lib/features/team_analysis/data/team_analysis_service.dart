import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/local_database.dart';
import '../../athletes/data/local_athlete_repository.dart';
import '../../evaluation/data/ability_profile_service.dart';
import '../../evaluation/data/local_evaluation_criteria_repository.dart';
import '../../evaluation/domain/ability_profile.dart';
import '../../evaluation/domain/evaluation_criteria_repository.dart';
import '../../measurements/data/local_measurement_item_repository.dart';
import '../../measurements/data/local_measurement_repository.dart';
import '../../measurements/domain/measurement_repository.dart';
import '../domain/team_analysis_models.dart';

part 'team_analysis_service.g.dart';

/// チーム分析画面が必要とするデータ一式を集計する。
/// [sessionId]を省略すると最新セッションを対象にする。
@riverpod
Future<TeamAnalysisData> teamAnalysisData(Ref ref, {String? sessionId}) async {
  final athleteRepo = ref.watch(athleteRepositoryProvider);
  final itemRepo = ref.watch(measurementItemRepositoryProvider);
  final measurementRepo = ref.watch(measurementRepositoryProvider);
  final criteriaRepo = ref.watch(evaluationCriteriaRepositoryProvider);

  final athletes = await athleteRepo.getAll();
  final items = await itemRepo.getAll();
  final sessions = await measurementRepo.getSessions(); // 測定日降順

  final selectedSession = sessionId == null
      ? (sessions.isEmpty ? null : sessions.first)
      : (sessions.where((s) => s.id == sessionId).firstOrNull ?? (sessions.isEmpty ? null : sessions.first));

  final selectedSessionRecords = selectedSession == null
      ? <MeasurementRecord>[]
      : await measurementRepo.getRecordsForSession(selectedSession.id);

  final datedRecords = await buildDatedRecords(sessions: sessions, measurementRepo: measurementRepo);

  final abilityByPosition = await _computeGroupAbilityProfiles(
    athletes: athletes,
    items: items,
    records: selectedSessionRecords,
    criteriaRepo: criteriaRepo,
    groupKey: (a) => a.position,
  );

  return TeamAnalysisData(
    athletes: athletes,
    items: items,
    sessions: sessions,
    selectedSession: selectedSession,
    selectedSessionRecords: selectedSessionRecords,
    datedRecords: datedRecords,
    abilityByPosition: abilityByPosition,
  );
}

/// 全セッションの記録を測定日付きで返す。年度別集計など他featureからも利用する。
Future<List<DatedRecord>> buildDatedRecords({
  required List<MeasurementSession> sessions,
  required MeasurementRepository measurementRepo,
}) async {
  final datedRecords = <DatedRecord>[];
  for (final session in sessions) {
    final records = await measurementRepo.getRecordsForSession(session.id);
    for (final record in records) {
      datedRecords.add(DatedRecord(record: record, measurementDate: session.measurementDate));
    }
  }
  return datedRecords;
}

/// [groupKey]でグルーピングした選手ごとに能力プロファイルを算出し、グループ内平均を返す。
/// [groupKey]がnullを返す選手（ポジション未設定など）はグルーピング対象外。
Future<Map<String, AbilityProfile>> _computeGroupAbilityProfiles({
  required List<Athlete> athletes,
  required List<MeasurementItem> items,
  required List<MeasurementRecord> records,
  required EvaluationCriteriaRepository criteriaRepo,
  required String? Function(Athlete) groupKey,
}) async {
  final profilesByGroup = <String, List<AbilityProfile>>{};

  for (final athlete in athletes) {
    final key = groupKey(athlete);
    if (key == null) continue;

    final athleteRecords = records.where((r) => r.athleteId == athlete.id).toList();
    if (athleteRecords.isEmpty) continue;

    final profile = await computeAthleteAbilityProfile(
      items: items,
      criteriaRepo: criteriaRepo,
      athleteRecords: athleteRecords,
      position: athlete.position,
    );
    profilesByGroup.putIfAbsent(key, () => []).add(profile);
  }

  return {
    for (final entry in profilesByGroup.entries) entry.key: AbilityProfile.average(entry.value),
  };
}
