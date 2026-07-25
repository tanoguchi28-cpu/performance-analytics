import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/features/team_session/data/team_session_storage.dart';
import 'package:performance_analytics/features/team_session/domain/staff_role.dart';
import 'package:performance_analytics/features/team_session/domain/team_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('未保存の場合はnullを返す', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = TeamSessionStorage(prefs);

    expect(storage.read(), isNull);
  });

  test('write→readで内容が復元される（選手ロール）', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = TeamSessionStorage(prefs);

    const session = TeamSession(
      teamId: 'ABCD1234',
      teamName: '〇〇高校バスケ部',
      role: StaffRole.player,
      athleteId: 'athlete-1',
      athleteName: '横田向星',
    );
    await storage.write(session);

    final restored = storage.read();
    expect(restored?.teamId, session.teamId);
    expect(restored?.teamName, session.teamName);
    expect(restored?.role, session.role);
    expect(restored?.athleteId, session.athleteId);
    expect(restored?.athleteName, session.athleteName);
  });

  test('スタッフロールではathleteId/athleteNameがnullのまま復元される', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = TeamSessionStorage(prefs);

    const session = TeamSession(teamId: 'ABCD1234', teamName: 'チームA', role: StaffRole.coach);
    await storage.write(session);

    final restored = storage.read();
    expect(restored?.athleteId, isNull);
    expect(restored?.athleteName, isNull);
  });

  test('clear()で保存内容が消える', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = TeamSessionStorage(prefs);

    await storage.write(
      const TeamSession(teamId: 'ABCD1234', teamName: 'チームA', role: StaffRole.headCoach),
    );
    await storage.clear();

    expect(storage.read(), isNull);
  });
}
