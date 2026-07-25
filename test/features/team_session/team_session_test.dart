import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/features/team_session/domain/staff_role.dart';
import 'package:performance_analytics/features/team_session/domain/team_session.dart';

void main() {
  group('TeamSession.copyWith', () {
    test('teamNameのみ更新し、他フィールドは維持される', () {
      const session = TeamSession(
        teamId: 'ABCD1234',
        teamName: '旧チーム名',
        role: StaffRole.player,
        athleteId: 'a1',
        athleteName: '横田向星',
      );

      final updated = session.copyWith(teamName: '新チーム名');

      expect(updated.teamName, '新チーム名');
      expect(updated.teamId, session.teamId);
      expect(updated.role, session.role);
      expect(updated.athleteId, session.athleteId);
      expect(updated.athleteName, session.athleteName);
    });

    test('引数省略時は変更なしのコピーになる', () {
      const session = TeamSession(teamId: 'ABCD1234', teamName: 'チームA', role: StaffRole.coach);
      final copy = session.copyWith();

      expect(copy.teamId, session.teamId);
      expect(copy.teamName, session.teamName);
      expect(copy.role, session.role);
    });
  });
}
