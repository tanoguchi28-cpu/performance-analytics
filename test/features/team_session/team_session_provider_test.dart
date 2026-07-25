import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/features/team_session/data/team_session_provider.dart';
import 'package:performance_analytics/features/team_session/domain/staff_role.dart';
import 'package:performance_analytics/features/team_session/domain/team_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('セッション未設定時はcanEditProviderがtrue（ローカル専用モードは無制限）', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(teamSessionProvider), isNull);
    expect(container.read(canEditProvider), isTrue);
  });

  test('setSessionでcanEditProviderが役割に応じて更新される', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(teamSessionProvider.notifier)
        .setSession(const TeamSession(teamId: 'ABCD1234', teamName: 'チームA', role: StaffRole.studentStaff));

    expect(container.read(teamSessionProvider)?.role, StaffRole.studentStaff);
    expect(container.read(canEditProvider), isFalse);
  });

  test('clearSessionでnullに戻る', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(teamSessionProvider.notifier)
        .setSession(const TeamSession(teamId: 'ABCD1234', teamName: 'チームA', role: StaffRole.headCoach));
    await container.read(teamSessionProvider.notifier).clearSession();

    expect(container.read(teamSessionProvider), isNull);
    expect(container.read(canEditProvider), isTrue);
  });
}
