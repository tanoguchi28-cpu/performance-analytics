import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/core/router/scaffold_with_nav.dart';
import 'package:performance_analytics/features/team_session/data/team_session_provider.dart';
import 'package:performance_analytics/features/team_session/domain/staff_role.dart';
import 'package:performance_analytics/features/team_session/domain/team_session.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child, {TeamSession? session}) {
    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        ShellRoute(
          builder: (_, __, shellChild) => child,
          routes: [
            GoRoute(path: '/dashboard', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/my-report', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/team-analysis', builder: (_, __) => const SizedBox()),
          ],
        ),
      ],
    );
    return ProviderScope(
      overrides: session == null ? [] : [teamSessionProvider.overrideWith(() => _FixedSession(session))],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('スタッフロールは6項目のナビゲーションが表示される', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      wrap(
        const ScaffoldWithNav(child: SizedBox()),
        session: const TeamSession(teamId: 'X', teamName: 'T', role: StaffRole.coach),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in ['ダッシュボード', '選手', '測定', 'ランキング', 'チーム分析', '設定']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('選手ロールは自分の記録・チーム分析の2項目のみ表示される', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      wrap(
        const ScaffoldWithNav(child: SizedBox()),
        session: const TeamSession(teamId: 'X', teamName: 'T', role: StaffRole.player, athleteId: 'a1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('自分の記録'), findsOneWidget);
    expect(find.text('チーム分析'), findsOneWidget);
    for (final label in ['ダッシュボード', '選手', '測定', 'ランキング', '設定']) {
      expect(find.text(label), findsNothing, reason: label);
    }
  });
}

class _FixedSession extends TeamSessionState {
  _FixedSession(this._session);
  final TeamSession _session;

  @override
  TeamSession? build() => _session;
}
