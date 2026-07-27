import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/local_database.dart';
import '../domain/evaluation_criteria_repository.dart';

/// チーム共有モード用の評価基準リポジトリ。
///
/// `evaluation_criteria`・`score_bands`テーブルへの直接アクセスはDB側で
/// 禁止しており、全て`team_id`必須のRPC関数経由で読み書きする
/// （docs/supabase_migration.md参照）。`score_bands.team_id`は非正規化列で、
/// DB側のトリガーが`criteria_id`から自動セットするため、クライアントからは送らない。
///
/// 評価基準・得点帯は選手数×項目数分[evaluate]から繰り返し参照される。ローカル版
/// （[LocalEvaluationCriteriaRepository]）と同様にitemKey単位・criteriaId単位で
/// メモリキャッシュし、変更系メソッド完了時に破棄することで、ダッシュボード等を
/// 開くたびに同じRPCをN+1回ネットワーク越しに叩くのを防ぐ。
class SupabaseEvaluationCriteriaRepository implements EvaluationCriteriaRepository {
  SupabaseEvaluationCriteriaRepository(this._client, this._teamId);

  final SupabaseClient _client;
  final String _teamId;

  final _criteriaCache = <String, List<EvaluationCriterion>>{};
  final _bandsCache = <String, List<ScoreBand>>{};

  void _invalidateCache() {
    _criteriaCache.clear();
    _bandsCache.clear();
  }

  @override
  Future<List<EvaluationCriterion>> getCriteriaForItem(String itemKey) async {
    final cached = _criteriaCache[itemKey];
    if (cached != null) return cached;

    final rows = await _client.rpc<List<dynamic>>(
      'evaluation_criteria_for_item',
      params: {'p_team_id': _teamId, 'p_item_key': itemKey},
    );
    final result = rows.cast<Map<String, dynamic>>().map(_criterionFromRow).toList();
    _criteriaCache[itemKey] = result;
    return result;
  }

  @override
  Future<List<ScoreBand>> getBands(String criteriaId) async {
    final cached = _bandsCache[criteriaId];
    if (cached != null) return cached;

    final rows = await _client.rpc<List<dynamic>>(
      'score_bands_for_criteria',
      params: {'p_team_id': _teamId, 'p_criteria_id': criteriaId},
    );
    final result = rows.cast<Map<String, dynamic>>().map(_bandFromRow).toList();
    _bandsCache[criteriaId] = result;
    return result;
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
    final rows = await _client.rpc<List<dynamic>>(
      'evaluation_criteria_create',
      params: {
        'p_team_id': _teamId,
        'p_item_key': itemKey,
        'p_name': name,
        'p_position': position,
      },
    );
    _invalidateCache();
    return (rows.single as Map<String, dynamic>)['id'] as String;
  }

  @override
  Future<void> deleteCriterion(String id) async {
    // score_bandsのcriteria_idはon delete cascade（docs/supabase_migration.md参照）
    // のため、基準セットの削除だけでよい。
    await _client.rpc<void>(
      'evaluation_criteria_delete',
      params: {'p_team_id': _teamId, 'p_id': id},
    );
    _invalidateCache();
  }

  @override
  Future<String> upsertBand({
    String? id,
    required String criteriaId,
    required int score,
    double? minValue,
    double? maxValue,
  }) async {
    final rows = await _client.rpc<List<dynamic>>(
      'score_bands_upsert',
      params: {
        'p_team_id': _teamId,
        'p_id': id,
        'p_criteria_id': criteriaId,
        'p_score': score,
        'p_min_value': minValue,
        'p_max_value': maxValue,
      },
    );
    _invalidateCache();
    return (rows.single as Map<String, dynamic>)['id'] as String;
  }

  @override
  Future<void> deleteBand(String id) async {
    await _client.rpc<void>(
      'score_bands_delete',
      params: {'p_team_id': _teamId, 'p_id': id},
    );
    _invalidateCache();
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
