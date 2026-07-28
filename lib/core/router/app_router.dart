import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/athletes/presentation/athlete_list_screen.dart';
import '../../features/athletes/presentation/athlete_detail_screen.dart';
import '../../features/athletes/presentation/athlete_form_screen.dart';
import '../../features/player_report/presentation/player_report_screen.dart';
import '../../features/measurements/presentation/measurement_session_list_screen.dart';
import '../../features/measurements/presentation/measurement_session_form_screen.dart';
import '../../features/measurements/presentation/measurement_session_detail_screen.dart';
import '../../features/measurements/presentation/measurement_entry_screen.dart';
import '../../features/excel_import/presentation/excel_import_screen.dart';
import '../../features/ranking/presentation/ranking_screen.dart';
import '../../features/team_analysis/presentation/team_analysis_screen.dart';
import '../../features/team_report/presentation/team_report_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/measurement_item_management_screen.dart';
import '../../features/settings/presentation/measurement_item_form_screen.dart';
import '../../features/settings/presentation/evaluation_criteria_management_screen.dart';
import '../../features/settings/presentation/team_settings_screen.dart';
import '../../features/settings/presentation/backup_screen.dart';
import '../../features/team_session/domain/team_session.dart';
import '../../main.dart' show currentTeamSession, teamSetupComplete;
import 'router_redirect.dart';
import 'scaffold_with_nav.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final TeamSession? session = currentTeamSession;
      return computeRedirect(
        matchedLocation: state.matchedLocation,
        teamSetupComplete: teamSetupComplete,
        session: session,
      );
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/my-report',
            builder: (_, __) => PlayerReportScreen(athleteId: currentTeamSession!.athleteId!),
          ),
          GoRoute(
            path: '/athletes',
            builder: (_, __) => const AthleteListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const AthleteFormScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => AthleteDetailScreen(
                  athleteId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, state) => AthleteFormScreen(
                      athleteId: state.pathParameters['id'],
                    ),
                  ),
                  GoRoute(
                    path: 'report',
                    builder: (_, state) => PlayerReportScreen(
                      athleteId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/measurements',
            builder: (_, __) => const MeasurementSessionListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const MeasurementSessionFormScreen(),
              ),
              GoRoute(
                path: 'import',
                builder: (_, __) => const ExcelImportScreen(),
              ),
              GoRoute(
                path: ':sessionId',
                builder: (_, state) => MeasurementSessionDetailScreen(
                  sessionId: state.pathParameters['sessionId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, state) => MeasurementSessionFormScreen(
                      sessionId: state.pathParameters['sessionId'],
                    ),
                  ),
                  GoRoute(
                    path: 'athletes/:athleteId',
                    builder: (_, state) => MeasurementEntryScreen(
                      sessionId: state.pathParameters['sessionId']!,
                      athleteId: state.pathParameters['athleteId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/ranking',
            builder: (_, __) => const RankingScreen(),
          ),
          GoRoute(
            path: '/team-analysis',
            builder: (_, __) => const TeamAnalysisScreen(),
            routes: [
              GoRoute(
                path: 'report',
                builder: (_, __) => const TeamReportScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'measurement-items',
                builder: (_, __) => const MeasurementItemManagementScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (_, __) => const MeasurementItemFormScreen(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (_, state) => MeasurementItemFormScreen(
                      itemId: state.pathParameters['id'],
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'evaluation-criteria',
                builder: (_, __) => const EvaluationCriteriaManagementScreen(),
              ),
              GoRoute(
                path: 'team',
                builder: (_, __) => const TeamSettingsScreen(),
              ),
              GoRoute(
                path: 'backup',
                builder: (_, __) => const BackupScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
