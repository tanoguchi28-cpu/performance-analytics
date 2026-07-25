import 'team.dart';

/// チームの新規登録・ID検索を行う抽象インターフェース。
/// チーム共有はSupabase接続が前提のため、ローカル実装は存在しない。
abstract class TeamRepository {
  /// 新しいチームを登録し、割り当てられたコードを含む[Team]を返す。
  Future<Team> createTeam(String name);

  /// [code]に一致するチームを検索する。見つからなければnull。
  Future<Team?> findTeam(String code);

  /// チーム名を更新する。
  Future<void> updateTeamName(String teamId, String name);
}
