import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/local_database.dart';
import '../domain/measurement_repository.dart';

/// チーム共有モード用の測定セッション・記録リポジトリ。全クエリを[_teamId]でスコープする。
/// `measurement_records`の`team_id`は非正規化列で、DB側のトリガーが
/// `session_id`から自動セットするため、クライアントからは書き込まない
/// （docs/supabase_migration.md参照）。
class SupabaseMeasurementRepository implements MeasurementRepository {
  SupabaseMeasurementRepository(this._client, this._teamId);

  final SupabaseClient _client;
  final String _teamId;
  static const _sessionsTable = 'measurement_sessions';
  static const _recordsTable = 'measurement_records';
  static const _uuid = Uuid();

  @override
  Future<List<MeasurementSession>> getSessions() async {
    final rows = await _client
        .from(_sessionsTable)
        .select()
        .eq('team_id', _teamId)
        .order('measurement_date', ascending: false);
    return rows.map(_sessionFromRow).toList();
  }

  @override
  Future<MeasurementSession?> getSession(String id) async {
    final row = await _client
        .from(_sessionsTable)
        .select()
        .eq('team_id', _teamId)
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : _sessionFromRow(row);
  }

  @override
  Future<String> createSession({
    required DateTime measurementDate,
    String? label,
    String? note,
  }) async {
    final row = await _client
        .from(_sessionsTable)
        .insert({
          'team_id': _teamId,
          'measurement_date': measurementDate.toIso8601String(),
          'label': label,
          'note': note,
        })
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<void> deleteSession(String id) async {
    // measurement_recordsのsession_idはon delete cascade（docs/supabase_migration.md参照）
    // のため、セッションの削除だけでよい。
    await _client.from(_sessionsTable).delete().eq('team_id', _teamId).eq('id', id);
  }

  @override
  Future<void> upsertRecord({
    required String athleteId,
    required String sessionId,
    required String itemId,
    required double value,
  }) async {
    // (athlete_id, session_id, item_id) のunique制約でonConflict上書きする。
    // team_idはDBトリガーがsession_idから自動セットするため送らない。
    await _client.from(_recordsTable).upsert(
      {
        'id': _uuid.v4(),
        'athlete_id': athleteId,
        'session_id': sessionId,
        'item_id': itemId,
        'value': value,
      },
      onConflict: 'athlete_id,session_id,item_id',
    );
  }

  @override
  Future<void> deleteRecord({
    required String athleteId,
    required String sessionId,
    required String itemId,
  }) async {
    await _client
        .from(_recordsTable)
        .delete()
        .eq('team_id', _teamId)
        .eq('athlete_id', athleteId)
        .eq('session_id', sessionId)
        .eq('item_id', itemId);
  }

  @override
  Future<List<MeasurementRecord>> getRecordsForAthlete(String athleteId) async {
    // measurement_dateの昇順で返す必要があるため、measurement_sessionsをネスト選択して
    // アプリ側でソートする。
    final rows = await _client
        .from(_recordsTable)
        .select('*, measurement_sessions!inner(measurement_date)')
        .eq('team_id', _teamId)
        .eq('athlete_id', athleteId);
    final sorted = rows.toList()
      ..sort((a, b) {
        final dateA = a['measurement_sessions']['measurement_date'] as String;
        final dateB = b['measurement_sessions']['measurement_date'] as String;
        return dateA.compareTo(dateB);
      });
    return sorted.map(_recordFromRow).toList();
  }

  @override
  Future<List<MeasurementRecord>> getRecordsForSession(String sessionId) async {
    final rows = await _client
        .from(_recordsTable)
        .select()
        .eq('team_id', _teamId)
        .eq('session_id', sessionId);
    return rows.map(_recordFromRow).toList();
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
