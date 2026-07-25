import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/local_database.dart';
import '../domain/evaluation_criteria_repository.dart';

/// チーム共有モード用の評価基準リポジトリ。全クエリを[_teamId]でスコープする。
/// `score_bands.team_id`は非正規化列で、DB側のトリガーが`criteria_id`から
/// 自動セットするため、クライアントからは書き込まない（docs/supabase_migration.md参照）。
class SupabaseEvaluationCriteriaRepository implements EvaluationCriteriaRepository {
  SupabaseEvaluationCriteriaRepository(this._client, this._teamId);

  final SupabaseClient _client;
  final String _teamId;
  static const _criteriaTable = 'evaluation_criteria';
  static const _bandsTable = 'score_bands';
  static const _uuid = Uuid();

  @override
  Future<List<EvaluationCriterion>> getCriteriaForItem(String itemKey) async {
    final rows = await _client
        .from(_criteriaTable)
        .select()
        .eq('team_id', _teamId)
        .eq('item_key', itemKey);
    return rows.map(_criterionFromRow).toList();
  }

  @override
  Future<List<ScoreBand>> getBands(String criteriaId) async {
    final rows = await _client
        .from(_bandsTable)
        .select()
        .eq('team_id', _teamId)
        .eq('criteria_id', criteriaId);
    return rows.map(_bandFromRow).toList();
  }

  @override
  Future<int?> evaluate({
    required String itemKey,
    required double value,
    String? position,
  }) async {
    final criteria = await getCriteriaForItem(itemKey);
    if (criteria.isEmpty) return null;

    EvaluationCriterion? findBy(bool Function(EvaluationCriterion) test) {
      for (final c in criteria) {
        if (test(c)) return c;
      }
      return null;
    }

    final matched = (position != null ? findBy((c) => c.position == position) : null) ??
        findBy((c) => c.position == null) ??
        criteria.first;

    final bands = await getBands(matched.id);
    for (final band in bands) {
      final aboveMin = band.minValue == null || value >= band.minValue!;
      final belowMax = band.maxValue == null || value <= band.maxValue!;
      if (aboveMin && belowMax) return band.score;
    }
    return null;
  }

  @override
  Future<String> createCriterion({
    required String itemKey,
    required String name,
    String? position,
  }) async {
    final row = await _client
        .from(_criteriaTable)
        .insert({'team_id': _teamId, 'item_key': itemKey, 'name': name, 'position': position})
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<void> deleteCriterion(String id) async {
    // score_bandsのcriteria_idにon delete cascadeを設定している前提（DDL参照）。
    await _client.from(_criteriaTable).delete().eq('team_id', _teamId).eq('id', id);
  }

  @override
  Future<String> upsertBand({
    String? id,
    required String criteriaId,
    required int score,
    double? minValue,
    double? maxValue,
  }) async {
    final bandId = id ?? _uuid.v4();
    await _client.from(_bandsTable).upsert({
      'id': bandId,
      'criteria_id': criteriaId,
      'score': score,
      'min_value': minValue,
      'max_value': maxValue,
    });
    return bandId;
  }

  @override
  Future<void> deleteBand(String id) async {
    await _client.from(_bandsTable).delete().eq('team_id', _teamId).eq('id', id);
  }

  EvaluationCriterion _criterionFromRow(Map<String, dynamic> row) {
    return EvaluationCriterion(
      id: row['id'] as String,
      name: row['name'] as String,
      itemKey: row['item_key'] as String,
      gender: row['gender'] as String?,
      ageGroupMin: row['age_group_min'] as int?,
      ageGroupMax: row['age_group_max'] as int?,
      position: row['position'] as String?,
    );
  }

  ScoreBand _bandFromRow(Map<String, dynamic> row) {
    return ScoreBand(
      id: row['id'] as String,
      criteriaId: row['criteria_id'] as String,
      minValue: (row['min_value'] as num?)?.toDouble(),
      maxValue: (row['max_value'] as num?)?.toDouble(),
      score: row['score'] as int,
    );
  }
}
