import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/core/router/router_redirect.dart';
import 'package:performance_analytics/features/team_session/domain/staff_role.dart';
import 'package:performance_analytics/features/team_session/domain/team_session.dart';

TeamSession _session(StaffRole role, {String? athleteId}) {
  return TeamSession(teamId: 'ABCD1234', teamName: 'テストチーム', role: role, athleteId: athleteId);
}

void main() {
  group('オンボーディング未完了', () {
    test('オンボーディング以外のパスは/onboardingへ', () {
      expect(
        computeRedirect(matchedLocation: '/dashboard', teamSetupComplete: false, session: null),
        '/onboarding',
      );
    });

    test('/onboarding自体はリダイレクトしない', () {
      expect(
        computeRedirect(matchedLocation: '/onboarding', teamSetupComplete: false, session: null),
        isNull,
      );
    });
  });

  group('オンボーディング完了・セッション無し（ローカル専用モード）', () {
    test('/onboardingにいたら/dashboardへ', () {
      expect(
        computeRedirect(matchedLocation: '/onboarding', teamSetupComplete: true, session: null),
        '/dashboard',
      );
    });

    test('全ルートに制限なくアクセスできる', () {
      for (final path in ['/dashboard', '/athletes', '/athletes/new', '/settings']) {
        expect(
          computeRedirect(matchedLocation: path, teamSetupComplete: true, session: null),
          isNull,
          reason: path,
        );
      }
    });
  });

  group('監督/コーチ/トレーナー（編集可能ロール）', () {
    for (final role in [StaffRole.headCoach, StaffRole.coach, StaffRole.trainer]) {
      test('${role.label}は全ルートにアクセスできる', () {
        for (final path in [
          '/dashboard',
          '/athletes',
          '/athletes/new',
          '/measurements/new',
          '/settings/measurement-items/new',
        ]) {
          expect(
            computeRedirect(matchedLocation: path, teamSetupComplete: true, session: _session(role)),
            isNull,
            reason: '$role: $path',
          );
        }
      });
    }
  });

  group('学生スタッフ（閲覧のみ）', () {
    test('通常の閲覧ルートにはアクセスできる', () {
      for (final path in ['/dashboard', '/athletes', '/measurements', '/settings']) {
        expect(
          computeRedirect(
            matchedLocation: path,
            teamSetupComplete: true,
            session: _session(StaffRole.studentStaff),
          ),
          isNull,
          reason: path,
        );
      }
    });

    test('新規作成専用ルートは一覧へリダイレクトされる', () {
      const cases = {
        '/athletes/new': '/athletes',
        '/measurements/new': '/measurements',
        '/measurements/import': '/measurements',
        '/settings/measurement-items/new': '/settings/measurement-items',
      };
      cases.forEach((path, expected) {
        expect(
          computeRedirect(
            matchedLocation: path,
            teamSetupComplete: true,
            session: _session(StaffRole.studentStaff),
          ),
          expected,
          reason: path,
        );
      });
    });
  });

  group('選手（自分の記録とチーム分析のみ）', () {
    test('/my-reportと/team-analysisはアクセスできる', () {
      for (final path in ['/my-report', '/team-analysis']) {
        expect(
          computeRedirect(
            matchedLocation: path,
            teamSetupComplete: true,
            session: _session(StaffRole.player, athleteId: 'a1'),
          ),
          isNull,
          reason: path,
        );
      }
    });

    test('チームレポート(/team-analysis/report)を含むそれ以外は/my-reportへリダイレクトされる', () {
      for (final path in [
        '/dashboard',
        '/athletes',
        '/athletes/a2',
        '/measurements',
        '/ranking',
        '/team-analysis/report',
        '/settings',
      ]) {
        expect(
          computeRedirect(
            matchedLocation: path,
            teamSetupComplete: true,
            session: _session(StaffRole.player, athleteId: 'a1'),
          ),
          '/my-report',
          reason: path,
        );
      }
    });
  });
}
