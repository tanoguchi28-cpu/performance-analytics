import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/local_database.dart';
import '../domain/measurement_repository.dart';

/// チーム共有モード用の測定セッション・記録リポジトリ。
///
/// `measurement_sessions`・`measurement_records`テーブルへの直接アクセスは
/// DB側で禁止しており、全て`team_id`必須のRPC関数経由で読み書きする
/// （docs/supabase_migration.md参照）。`measurement_records.team_id`は
/// 非正規化列で、DB側のトリガーが`session_id`から自動セットするため、
/// クライアントからは送らない。
class SupabaseMeasurementRepository implements MeasurementRepository {
  SupabaseMeasurementRepository(this._client, this._teamId);

  final SupabaseClient _client;
  final String _teamId;

  @override
  Future<List<MeasurementSession>> getSessions() async {
    final rows = await _client.rpc<List<dynamic>>(
      'measurement_sessions_list',
      params: {'p_team_id': _teamId},
    );
    return rows.cast<Map<String, dynamic>>().map(_sessionFromRow).toList();
  }

  @override
  Future<MeasurementSession?> getSession(String id) async {
    final rows = await _client.rpc<List<dynamic>>(
      'measurement_sessions_get',
      params: {'p_team_id': _teamId, 'p_id': id},
    );
    if (rows.isEmpty) return null;
    return _sessionFromRow(rows.single as Map<String, dynamic>);
  }

  @override
  Future<String> createSession({
    required DateTime measurementDate,
    String? label,
    String? note,
  }) async {
    final rows = await _client.rpc<List<dynamic>>(
      'measurement_sessions_create',
      params: {
        'p_team_id': _teamId,
        'p_measurement_date': measurementDate.toIso8601String().substring(0, 10),
        'p_label': label,
        'p_note': note,
      },
    );
    return (rows.single as Map<String, dynamic>)['id'] as String;
  }

  @override
  Future<void> deleteSession(String id) async {
    // measurement_recordsのsession_idはon delete cascade（docs/supabase_migration.md参照）
    // のため、セッションの削除だけでよい。
    await _client.rpc<void>(
      'measurement_sessions_delete',
      params: {'p_team_id': _teamId, 'p_id': id},
    );
  }

  @override
  Future<void> upsertRecord({
    required String athleteId,
    required String sessionId,
    required String itemId,
    required double value,
  }) async {
    await _client.rpc<void>(
      'measurement_records_upsert',
      params: {
        'p_team_id': _teamId,
        'p_athlete_id': athleteId,
        'p_session_id': sessionId,
        'p_item_id': itemId,
        'p_value': value,
      },
    );
  }

  @override
  Future<void> deleteRecord({
    required String athleteId,
    required String sessionId,
    required String itemId,
  }) async {
    await _client.rpc<void>(
      'measurement_records_delete',
      params: {
        'p_team_id': _teamId,
        'p_athlete_id': athleteId,
        'p_session_id': sessionId,
        'p_item_id': itemId,
      },
    );
  }

  @override
  Future<List<MeasurementRecord>> getRecordsForAthlete(String athleteId) async {
    final rows = await _client.rpc<List<dynamic>>(
      'measurement_records_for_athlete',
      params: {'p_team_id': _teamId, 'p_athlete_id': athleteId},
    );
    return rows.cast<Map<String, dynamic>>().map(_recordFromRow).toList();
  }

  @override
  Future<List<MeasurementRecord>> getRecordsForSession(String sessionId) async {
    final rows = await _client.rpc<List<dynamic>>(
      'measurement_records_for_session',
      params: {'p_team_id': _teamId, 'p_session_id': sessionId},
    );
    return rows.cast<Map<String, dynamic>>().map(_recordFromRow).toList();
  }

  MeasurementSession _sessionFromRow(Map<String, dynamic> row) {
    return MeasurementSession(
      id: row['id'] as String,
      measurementDate: DateTime.parse(row['measurement_date'] as String),
      label: row['label'] as String?,
      note: row['note'] as String?,
    );
  }

  MeasurementRecord _recordFromRow(Map<String, dynamic> row) {
    return MeasurementRecord(
      id: row['id'] as String,
      athleteId: row['athlete_id'] as String,
      sessionId: row['session_id'] as String,
      itemId: row['item_id'] as String,
      value: (row['value'] as num).toDouble(),
    );
  }
}
