import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/ability_category.dart';
import '../../../core/database/local_database.dart';
import '../domain/measurement_item_repository.dart';

/// チーム共有モード用の測定項目リポジトリ。
///
/// `measurement_items`テーブルへの直接アクセスはDB側で禁止しており、全て
/// `team_id`必須のRPC関数（`measurement_items_*`）経由で読み書きする
/// （docs/supabase_migration.md参照）。
class SupabaseMeasurementItemRepository implements MeasurementItemRepository {
  SupabaseMeasurementItemRepository(this._client, this._teamId);

  final SupabaseClient _client;
  final String _teamId;

  @override
  Future<List<MeasurementItem>> getAll({bool activeOnly = true}) async {
    final rows = await _client.rpc<List<dynamic>>(
      'measurement_items_list',
      params: {'p_team_id': _teamId, 'p_active_only': activeOnly},
    );
    return rows.cast<Map<String, dynamic>>().map(_fromRow).toList();
  }

  @override
  Future<MeasurementItem?> getByKey(String key) async {
    final rows = await _client.rpc<List<dynamic>>(
      'measurement_items_get_by_key',
      params: {'p_team_id': _teamId, 'p_key': key},
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.single as Map<String, dynamic>);
  }

  @override
  Future<String> create(MeasurementItemsCompanion companion) async {
    final rows = await _client.rpc<List<dynamic>>(
      'measurement_items_create',
      params: {'p_team_id': _teamId, 'p_data': _toRow(companion)},
    );
    return (rows.single as Map<String, dynamic>)['id'] as String;
  }

  @override
  Future<void> update(String id, MeasurementItemsCompanion companion) async {
    await _client.rpc<void>(
      'measurement_items_update',
      params: {'p_team_id': _teamId, 'p_id': id, 'p_patch': _toRow(companion)},
    );
  }

  @override
  Future<void> deactivate(String id) async {
    await _client.rpc<void>(
      'measurement_items_deactivate',
      params: {'p_team_id': _teamId, 'p_id': id},
    );
  }

  MeasurementItem _fromRow(Map<String, dynamic> row) {
    return MeasurementItem(
      id: row['id'] as String,
      key: row['key'] as String,
      name: row['name'] as String,
      unit: row['unit'] as String,
      higherIsBetter: row['higher_is_better'] as bool,
      abilityCategory: AbilityCategory.values.byName(row['ability_category'] as String),
      isActive: row['is_active'] as bool,
      sortOrder: row['sort_order'] as int,
    );
  }

  Map<String, dynamic> _toRow(MeasurementItemsCompanion c) {
    final row = <String, dynamic>{};
    if (c.id.present) row['id'] = c.id.value;
    if (c.key.present) row['key'] = c.key.value;
    if (c.name.present) row['name'] = c.name.value;
    if (c.unit.present) row['unit'] = c.unit.value;
    if (c.higherIsBetter.present) row['higher_is_better'] = c.higherIsBetter.value;
    if (c.abilityCategory.present) row['ability_category'] = c.abilityCategory.value.name;
    if (c.isActive.present) row['is_active'] = c.isActive.value;
    if (c.sortOrder.present) row['sort_order'] = c.sortOrder.value;
    return row;
  }
}
