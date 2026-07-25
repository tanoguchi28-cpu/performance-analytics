import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart' show currentTeamSession, teamSetupComplete;
import '../domain/team_session.dart';
import 'team_session_storage.dart';

part 'team_session_provider.g.dart';

/// [currentTeamSession]（main.dartのグローバル、ルーターが同期参照）をリアクティブに
/// 公開するプロバイダ。オンボーディング完了時・サインアウト時に画面側から更新する。
@riverpod
class TeamSessionState extends _$TeamSessionState {
  @override
  TeamSession? build() => currentTeamSession;

  Future<void> setSession(TeamSession session) async {
    currentTeamSession = session;
    teamSetupComplete = true;
    state = session;

    final prefs = await SharedPreferences.getInstance();
    await TeamSessionStorage(prefs).write(session);
    await prefs.setBool('team_setup_complete', true);
  }

  Future<void> clearSession() async {
    currentTeamSession = null;
    teamSetupComplete = false;
    state = null;

    final prefs = await SharedPreferences.getInstance();
    await TeamSessionStorage(prefs).clear();
    await prefs.setBool('team_setup_complete', false);
  }
}

final teamSessionProvider = teamSessionStateProvider;

/// 全データの閲覧・編集が可能か。チームセッションが無い（ローカル専用モード）場合は
/// 従来通り無制限に編集可能として扱う。
final canEditProvider = Provider<bool>((ref) {
  final session = ref.watch(teamSessionProvider);
  return session == null || session.role.canEdit;
});
