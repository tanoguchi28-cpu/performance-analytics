import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/providers/supabase_provider.dart';
import '../domain/team.dart';
import '../domain/team_repository.dart';
import '../../../core/utils/team_code_generator.dart';

part 'supabase_team_repository.g.dart';

@riverpod
TeamRepository teamRepository(Ref ref) {
  return SupabaseTeamRepository(ref.watch(supabaseProvider));
}

/// チームの新規登録・検索は`teams`テーブルへ直接アクセスせず、
/// SECURITY DEFINERのRPC(`create_team`/`find_team`/`rename_team`)経由でのみ行う。
/// `teams`テーブルは直接SELECT/INSERT/UPDATEできないようRLSで塞がれている
/// （チームIDの一覧取得・総当たり収集を防ぐため）。docs/supabase_migration.md参照。
class SupabaseTeamRepository implements TeamRepository {
  SupabaseTeamRepository(this._client);

  final SupabaseClient _client;
  static const _maxRetries = 5;

  @override
  Future<Team> createTeam(String name) async {
    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final code = TeamCodeGenerator.generate();
      try {
        final rows = await _client.rpc<List<dynamic>>(
          'create_team',
          params: {'p_id': code, 'p_name': name},
        );
        final row = rows.single as Map<String, dynamic>;
        return _fromRow(row);
      } on PostgrestException catch (e) {
        if (e.code == '23505') continue; // 一意制約違反: コードを生成し直してリトライ
        rethrow;
      }
    }
    throw StateError('チームIDの生成に失敗しました。もう一度お試しください。');
  }

  @override
  Future<Team?> findTeam(String code) async {
    final rows = await _client.rpc<List<dynamic>>(
      'find_team',
      params: {'p_code': code},
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.single as Map<String, dynamic>);
  }

  @override
  Future<void> updateTeamName(String teamId, String name) async {
    await _client.rpc<List<dynamic>>(
      'rename_team',
      params: {'p_id': teamId, 'p_name': name},
    );
  }

  Team _fromRow(Map<String, dynamic> row) {
    return Team(
      id: row['id'] as String,
      name: row['name'] as String,
      createdAt: row['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(row['created_at'] as String),
    );
  }
}
