import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/ability_category.dart';
import '../../../core/database/local_database.dart';
import '../domain/measurement_item_repository.dart';

/// チーム共有モード用の測定項目リポジトリ。全クエリを[_teamId]でスコープする。
class SupabaseMeasurementItemRepository implements MeasurementItemRepository {
  SupabaseMeasurementItemRepository(this._client, this._teamId);

  final SupabaseClient _client;
  final String _teamId;
  static const _table = 'measurement_items';

  @override
  Future<List<MeasurementItem>> getAll({bool activeOnly = true}) async {
    var query = _client.from(_table).select().eq('team_id', _teamId);
    if (activeOnly) {
      query = query.eq('is_active', true);
    }
    final rows = await query.order('sort_order');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<MeasurementItem?> getByKey(String key) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('team_id', _teamId)
        .eq('key', key)
        .maybeSingle();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<String> create(MeasurementItemsCompanion companion) async {
    final row = _toRow(companion)..['team_id'] = _teamId;
    final result = await _client.from(_table).insert(row).select().single();
    return result['id'] as String;
  }

  @override
  Future<void> update(String id, MeasurementItemsCompanion companion) async {
    await _client.from(_table).update(_toRow(companion)).eq('team_id', _teamId).eq('id', id);
  }

  @override
  Future<void> deactivate(String id) async {
    await _client
        .from(_table)
        .update({'is_active': false})
        .eq('team_id', _teamId)
        .eq('id', id);
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
