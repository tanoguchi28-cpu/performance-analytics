import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:performance_analytics/app.dart';
import 'package:performance_analytics/core/database/database_provider.dart';
import 'package:performance_analytics/core/database/local_database.dart';
import 'package:performance_analytics/features/onboarding/presentation/onboarding_screen.dart';
import 'package:performance_analytics/features/team_session/data/supabase_team_repository.dart';
import 'package:performance_analytics/features/team_session/domain/team.dart';
import 'package:performance_analytics/features/team_session/domain/team_repository.dart';
import 'package:performance_analytics/main.dart' as app_main;
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTeamRepository implements TeamRepository {
  final Map<String, Team> teams = {};

  @override
  Future<Team> createTeam(String name) async {
    final team = Team(id: 'TESTCODE', name: name, createdAt: DateTime(2026, 1, 1));
    teams[team.id] = team;
    return team;
  }

  @override
  Future<Team?> findTeam(String code) async => teams[code];

  @override
  Future<void> updateTeamName(String teamId, String name) async {
    final existing = teams[teamId];
    if (existing != null) {
      teams[teamId] = Team(id: teamId, name: name, createdAt: existing.createdAt);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late _FakeTeamRepository fakeTeamRepo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fakeTeamRepo = _FakeTeamRepository();
    app_main.teamSetupComplete = false;
    app_main.currentTeamSession = null;
  });

  tearDown(() async {
    await db.close();
    app_main.teamSetupComplete = false;
    app_main.currentTeamSession = null;
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          teamRepositoryProvider.overrideWithValue(fakeTeamRepo),
        ],
        child: const PerformanceAnalyticsApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// 選手選択ステップ（Supabaseの選手一覧取得）まで到達するテスト用に、
  /// [OnboardingScreen.fetchRoster]を差し込める最小限のルーターでアプリを起動する。
  Future<void> pumpAppWithRoster(
    WidgetTester tester,
    Future<List<Athlete>> Function(WidgetRef ref, String teamId) fetchRoster,
  ) async {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => OnboardingScreen(fetchRoster: fetchRoster),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const Scaffold(body: Text('DASHBOARD_STUB')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          teamRepositoryProvider.overrideWithValue(fakeTeamRepo),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('新規チーム登録→役割選択(監督)でセッションが確定しダッシュボードへ進む', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('新規チーム登録（代表者の方）'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'チーム名'), 'テスト高校バスケ部');
    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();

    // 発行されたコードが表示される
    expect(find.text('TESTCODE'), findsOneWidget);

    await tester.tap(find.text('次へ（自分の種別を選択）'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('監督'));
    await tester.pumpAndSettle();
    expect(find.text('この種別でよろしいですか？'), findsOneWidget);
    await tester.tap(find.text('はい'));
    await tester.pumpAndSettle();

    expect(find.text('ダッシュボード'), findsWidgets);
    expect(app_main.currentTeamSession?.teamId, 'TESTCODE');
    expect(app_main.currentTeamSession?.role.label, '監督');
  });

  testWidgets('チームIDで参加→存在しないIDはエラー表示', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('チームIDで参加'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'チームID'), 'NOTFOUND');
    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();

    expect(find.text('IDが見つかりません'), findsOneWidget);
  });

  testWidgets('チームIDで参加→学生スタッフとして選択できる', (tester) async {
    await fakeTeamRepo.createTeam('参加先チーム');
    // createTeamで割り振られるコードは常に'TESTCODE'固定（フェイク実装）。
    await pumpApp(tester);

    await tester.tap(find.text('チームIDで参加'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'チームID'), 'TESTCODE');
    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('学生スタッフ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('はい'));
    await tester.pumpAndSettle();

    expect(app_main.currentTeamSession?.role.label, '学生スタッフ');
    expect(app_main.currentTeamSession?.athleteId, isNull);
  });

  testWidgets('選手を選択→名簿が空なら専用の空状態が表示され先に進めない', (tester) async {
    await fakeTeamRepo.createTeam('参加先チーム');
    await pumpAppWithRoster(tester, (ref, teamId) async => const []);

    await tester.tap(find.text('チームIDで参加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'チームID'), 'TESTCODE');
    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('選手'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('はい'));
    await tester.pumpAndSettle();

    expect(find.textContaining('まだあなたの名前が選手として登録されていません'), findsOneWidget);
    expect(app_main.currentTeamSession, isNull);
  });

  testWidgets('選手を選択→名簿から自分を選ぶとathleteIdが紐付く', (tester) async {
    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'a1', name: '横田向星', grade: 2, position: const Value('G')),
        );
    await fakeTeamRepo.createTeam('参加先チーム');
    await pumpAppWithRoster(tester, (ref, teamId) => db.select(db.athletes).get());

    await tester.tap(find.text('チームIDで参加'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'チームID'), 'TESTCODE');
    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('選手'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('はい'));
    await tester.pumpAndSettle();

    expect(find.text('横田向星'), findsOneWidget);
    await tester.tap(find.text('横田向星'));
    await tester.pumpAndSettle();

    expect(find.text('ご本人ですか？'), findsOneWidget);
    await tester.tap(find.text('はい'));
    await tester.pumpAndSettle();

    expect(app_main.currentTeamSession?.athleteId, 'a1');
    expect(app_main.currentTeamSession?.athleteName, '横田向星');
  });
}
