import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/features/team_session/domain/staff_role.dart';

void main() {
  group('StaffRole.canEdit', () {
    test('監督・コーチ・トレーナーは編集可能', () {
      expect(StaffRole.headCoach.canEdit, isTrue);
      expect(StaffRole.coach.canEdit, isTrue);
      expect(StaffRole.trainer.canEdit, isTrue);
    });

    test('学生スタッフ・選手は編集不可', () {
      expect(StaffRole.studentStaff.canEdit, isFalse);
      expect(StaffRole.player.canEdit, isFalse);
    });
  });

  group('StaffRole.isPlayer', () {
    test('選手のみtrue', () {
      for (final role in StaffRole.values) {
        expect(role.isPlayer, role == StaffRole.player);
      }
    });
  });

  test('全ロールにラベルが設定されている', () {
    for (final role in StaffRole.values) {
      expect(role.label, isNotEmpty);
    }
  });
}
