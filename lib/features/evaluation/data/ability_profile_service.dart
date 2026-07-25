import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/ability_category.dart';
import '../../../core/database/local_database.dart';
import '../../athletes/data/local_athlete_repository.dart';
import '../../measurements/data/local_measurement_item_repository.dart';
import '../../measurements/data/local_measurement_repository.dart';
import '../domain/ability_profile.dart';
import '../domain/evaluation_criteria_repository.dart';
import 'local_evaluation_criteria_repository.dart';

part 'ability_profile_service.g.dart';

/// 選手1名の測定記録群から[AbilityProfile]を組み立てる（評価基準エンジンの本体）。
/// DBアクセスは呼び出し側が済ませたデータを渡す形にして、ロジック部分を
/// 純粋な[AbilityProfile.compute]に委譲する。
Future<AbilityProfile> computeAthleteAbilityProfile({
  required List<MeasurementItem> items,
  required EvaluationCriteriaRepository criteriaRepo,
  required List<MeasurementRecord> athleteRecords,
  String? position,
}) async {
  final itemById = {for (final i in items) i.id: i};

  final itemAbilityCategories = <String, AbilityCategory>{
    for (final i in items)
      if (i.abilityCategory != AbilityCategory.none) i.id: i.abilityCategory,
  };

  final itemScores = <String, int?>{};
  for (final record in athleteRecords) {
    final item = itemById[record.itemId];
    if (item == null || item.abilityCategory == AbilityCategory.none) continue;
    itemScores[record.itemId] = await criteriaRepo.evaluate(
      itemKey: item.key,
      value: record.value,
      position: position,
    );
  }

  return AbilityProfile.compute(
    itemAbilityCategories: itemAbilityCategories,
    itemScores: itemScores,
  );
}

/// 指定セッションにおける選手の[AbilityProfile]をriverpod経由で取得する。
@riverpod
Future<AbilityProfile> athleteAbilityProfile(
  Ref ref, {
  required String athleteId,
  required String sessionId,
}) async {
  final athleteRepo = ref.watch(athleteRepositoryProvider);
  final measurementRepo = ref.watch(measurementRepositoryProvider);
  final itemRepo = ref.watch(measurementItemRepositoryProvider);
  final criteriaRepo = ref.watch(evaluationCriteriaRepositoryProvider);

  final athlete = await athleteRepo.getById(athleteId);
  final items = await itemRepo.getAll();
  final sessionRecords = await measurementRepo.getRecordsForSession(sessionId);
  final athleteRecords = sessionRecords.where((r) => r.athleteId == athleteId).toList();

  return computeAthleteAbilityProfile(
    items: items,
    criteriaRepo: criteriaRepo,
    athleteRecords: athleteRecords,
    position: athlete?.position,
  );
}
