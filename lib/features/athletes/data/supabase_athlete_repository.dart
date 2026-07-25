import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/local_database.dart';
import '../domain/athlete_repository.dart';

/// チーム共有モード用の選手リポジトリ。
///
/// `athletes`テーブルへの直接アクセス（PostgREST経由）はDB側で禁止しており、
/// 全て`team_id`必須のRPC関数（`athletes_*`）経由で読み書きする。これにより
/// 正しいチームIDを知らない限りデータへアクセスできない（docs/supabase_migration.md参照）。
/// `athleteRepositoryProvider`（`local_athlete_repository.dart`）から
/// チームセッションがある場合にのみ構築される。
class SupabaseAthleteRepository implements AthleteRepository {
  SupabaseAthleteRepository(this._client, this._teamId);

  final SupabaseClient _client;
  final String _teamId;

  @override
  Future<List<Athlete>> getAll({bool activeOnly = true}) async {
    final rows = await _client.rpc<List<dynamic>>(
      'athletes_list',
      params: {'p_team_id': _teamId, 'p_active_only': activeOnly},
    );
    return rows.cast<Map<String, dynamic>>().map(_fromRow).toList();
  }

  @override
  Future<Athlete?> getById(String id) async {
    final rows = await _client.rpc<List<dynamic>>(
      'athletes_get',
      params: {'p_team_id': _teamId, 'p_id': id},
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.single as Map<String, dynamic>);
  }

  @override
  Future<String> create(AthletesCompanion companion) async {
    final rows = await _client.rpc<List<dynamic>>(
      'athletes_create',
      params: {'p_team_id': _teamId, 'p_data': _toRow(companion)},
    );
    return (rows.single as Map<String, dynamic>)['id'] as String;
  }

  @override
  Future<void> update(String id, AthletesCompanion companion) async {
    await _client.rpc<void>(
      'athletes_update',
      params: {'p_team_id': _teamId, 'p_id': id, 'p_patch': _toRow(companion)},
    );
  }

  @override
  Future<void> deactivate(String id) async {
    await _client.rpc<void>(
      'athletes_deactivate',
      params: {'p_team_id': _teamId, 'p_id': id},
    );
  }

  @override
  Future<void> delete(String id) async {
    // measurement_recordsのathlete_idはon delete cascade（docs/supabase_migration.md参照）
    // のため、選手の削除だけでよい。
    await _client.rpc<void>(
      'athletes_delete',
      params: {'p_team_id': _teamId, 'p_id': id},
    );
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
