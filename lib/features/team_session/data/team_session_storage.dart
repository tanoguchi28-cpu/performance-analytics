import 'package:shared_preferences/shared_preferences.dart';

import '../domain/staff_role.dart';
import '../domain/team_session.dart';

const _keyTeamId = 'team_id';
const _keyTeamName = 'team_name';
const _keyStaffRole = 'staff_role';
const _keyAthleteId = 'session_athlete_id';
const _keyAthleteName = 'session_athlete_name';

/// [TeamSession]をSharedPreferencesへ永続化する。
class TeamSessionStorage {
  TeamSessionStorage(this._prefs);

  final SharedPreferences _prefs;

  /// 保存済みのセッションを読み込む。未保存/不整合ならnull。
  TeamSession? read() {
    final teamId = _prefs.getString(_keyTeamId);
    final teamName = _prefs.getString(_keyTeamName);
    final roleName = _prefs.getString(_keyStaffRole);
    if (teamId == null || teamName == null || roleName == null) return null;

    final role = StaffRole.values.where((r) => r.name == roleName).firstOrNull;
    if (role == null) return null;

    return TeamSession(
      teamId: teamId,
      teamName: teamName,
      role: role,
      athleteId: _prefs.getString(_keyAthleteId),
      athleteName: _prefs.getString(_keyAthleteName),
    );
  }

  Future<void> write(TeamSession session) async {
    await _prefs.setString(_keyTeamId, session.teamId);
    await _prefs.setString(_keyTeamName, session.teamName);
    await _prefs.setString(_keyStaffRole, session.role.name);
    if (session.athleteId != null) {
      await _prefs.setString(_keyAthleteId, session.athleteId!);
    } else {
      await _prefs.remove(_keyAthleteId);
    }
    if (session.athleteName != null) {
      await _prefs.setString(_keyAthleteName, session.athleteName!);
    } else {
      await _prefs.remove(_keyAthleteName);
    }
  }

  Future<void> clear() async {
    await _prefs.remove(_keyTeamId);
    await _prefs.remove(_keyTeamName);
    await _prefs.remove(_keyStaffRole);
    await _prefs.remove(_keyAthleteId);
    await _prefs.remove(_keyAthleteName);
  }
}
