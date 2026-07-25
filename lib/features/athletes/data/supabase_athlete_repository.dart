import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/local_database.dart';
import '../domain/athlete_repository.dart';

/// チーム共有モード用の選手リポジトリ。全クエリを[_teamId]でスコープする。
/// `athleteRepositoryProvider`（`local_athlete_repository.dart`）から
/// チームセッションがある場合にのみ構築される。
class SupabaseAthleteRepository implements AthleteRepository {
  SupabaseAthleteRepository(this._client, this._teamId);

  final SupabaseClient _client;
  final String _teamId;
  static const _table = 'athletes';

  @override
  Future<List<Athlete>> getAll({bool activeOnly = true}) async {
    var query = _client.from(_table).select().eq('team_id', _teamId);
    if (activeOnly) {
      query = query.eq('is_active', true);
    }
    final rows = await query.order('name');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Athlete?> getById(String id) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('team_id', _teamId)
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<String> create(AthletesCompanion companion) async {
    final row = _toRow(companion)..['team_id'] = _teamId;
    final result = await _client.from(_table).insert(row).select().single();
    return result['id'] as String;
  }

  @override
  Future<void> update(String id, AthletesCompanion companion) async {
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

  @override
  Future<void> delete(String id) async {
    // measurement_recordsのathlete_idはon delete cascade（docs/supabase_migration.md参照）
    // のため、選手の削除だけでよい。
    await _client.from(_table).delete().eq('team_id', _teamId).eq('id', id);
  }

  Athlete _fromRow(Map<String, dynamic> row) {
    return Athlete(
      id: row['id'] as String,
      name: row['name'] as String,
      kana: row['kana'] as String?,
      grade: row['grade'] as int,
      position: row['position'] as String?,
      birthDate: row['birth_date'] == null ? null : DateTime.parse(row['birth_date'] as String),
      photoPath: row['photo_path'] as String?,
      jerseyNumber: row['jersey_number'] as int?,
      isActive: row['is_active'] as bool,
      coachComment: row['coach_comment'] as String?,
    );
  }

  /// [AthletesCompanion]のうち値が設定されている(`Value.present`)フィールドのみを
  /// snake_caseの行データに変換する。未設定フィールドは更新対象から除外される。
  Map<String, dynamic> _toRow(AthletesCompanion c) {
    final row = <String, dynamic>{};
    if (c.id.present) row['id'] = c.id.value;
    if (c.name.present) row['name'] = c.name.value;
    if (c.kana.present) row['kana'] = c.kana.value;
    if (c.grade.present) row['grade'] = c.grade.value;
    if (c.position.present) row['position'] = c.position.value;
    if (c.birthDate.present) row['birth_date'] = c.birthDate.value?.toIso8601String();
    if (c.photoPath.present) row['photo_path'] = c.photoPath.value;
    if (c.jerseyNumber.present) row['jersey_number'] = c.jerseyNumber.value;
    if (c.isActive.present) row['is_active'] = c.isActive.value;
    if (c.coachComment.present) row['coach_comment'] = c.coachComment.value;
    return row;
  }
}
