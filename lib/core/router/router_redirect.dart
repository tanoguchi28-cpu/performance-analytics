import '../../features/team_session/domain/team_session.dart';

/// 新規作成専用ルート（編集不可ロールがアクセスした場合、対応する一覧へ戻す）。
/// key: リダイレクト対象のパスprefix, value: リダイレクト先。
const _createOnlyRedirects = {
  '/athletes/new': '/athletes',
  '/measurements/new': '/measurements',
  '/measurements/import': '/measurements',
  '/settings/measurement-items/new': '/settings/measurement-items',
};

/// 選手ロールが閲覧を許可されているルート（完全一致。サブルートは含まない）。
const _playerAllowedLocations = {'/my-report', '/team-analysis'};

/// go_routerの`redirect`本体。テストしやすいよう純粋関数として切り出している。
String? computeRedirect({
  required String matchedLocation,
  required bool teamSetupComplete,
  required TeamSession? session,
}) {
  final atOnboarding = matchedLocation == '/onboarding';
  if (!teamSetupComplete && !atOnboarding) return '/onboarding';
  if (teamSetupComplete && atOnboarding) return '/dashboard';
  if (session == null) return null;

  if (session.role.isPlayer) {
    if (!_playerAllowedLocations.contains(matchedLocation)) return '/my-report';
    return null;
  }

  if (!session.role.canEdit) {
    for (final entry in _createOnlyRedirects.entries) {
      if (matchedLocation.startsWith(entry.key)) return entry.value;
    }
  }

  return null;
}
