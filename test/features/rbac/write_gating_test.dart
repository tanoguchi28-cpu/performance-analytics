import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/app.dart';
import 'package:performance_analytics/core/database/database_provider.dart';
import 'package:performance_analytics/core/database/local_database.dart';
import 'package:performance_analytics/features/team_session/data/team_session_provider.dart';
import 'package:performance_analytics/features/team_session/domain/staff_role.dart';
import 'package:performance_analytics/features/team_session/domain/team_session.dart';
import 'package:performance_analytics/main.dart' as app_main;
import 'package:shared_preferences/shared_preferences.dart';

class _FixedSession extends TeamSessionState {
  _FixedSession(this._session);
  final TeamSession? _session;

  @override
  TeamSession? build() => _session;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    app_main.teamSetupComplete = true;
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester, {TeamSession? session}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          teamSessionProvider.overrideWith(() => _FixedSession(session)),
        ],
        child: const PerformanceAnalyticsApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('学生スタッフは選手一覧に追加ボタンが表示されない', (tester) async {
    await pumpApp(
      tester,
      session: const TeamSession(teamId: 'X', teamName: 'T', role: StaffRole.studentStaff),
    );

    await tester.tap(find.text('選手'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('選手を登録'), findsNothing);
  });

  testWidgets('監督は選手一覧に追加ボタンが表示される', (tester) async {
    await pumpApp(
      tester,
      session: const TeamSession(teamId: 'X', teamName: 'T', role: StaffRole.headCoach),
    );

    await tester.tap(find.text('選手'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('選手を登録'), findsOneWidget);
  });

  testWidgets('学生スタッフは選手詳細に編集・削除アイコンが表示されない', (tester) async {
    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'p1', name: '横田向星', grade: 2, position: const Value('G')),
        );
    await pumpApp(
      tester,
      session: const TeamSession(teamId: 'X', teamName: 'T', role: StaffRole.studentStaff),
    );

    await tester.tap(find.text('選手'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('横田向星'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('編集'), findsNothing);
    expect(find.byTooltip('削除'), findsNothing);
  });

  testWidgets('学生スタッフは測定項目管理に追加ボタンが表示されない', (tester) async {
    await pumpApp(
      tester,
      session: const TeamSession(teamId: 'X', teamName: 'T', role: StaffRole.studentStaff),
    );

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('測定項目管理'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('項目を追加'), findsNothing);
  });

  testWidgets('チーム共有モードでは設定画面にチーム情報が表示されバックアップは非表示', (tester) async {
    await pumpApp(
      tester,
      session: const TeamSession(teamId: 'ABCD1234', teamName: '〇〇高校', role: StaffRole.headCoach),
    );

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();

    expect(find.text('〇〇高校'), findsOneWidget);
    expect(find.textContaining('ABCD1234'), findsOneWidget);
    expect(find.text('データバックアップ'), findsNothing);
    expect(find.text('チームを切り替え'), findsOneWidget);
  });

  testWidgets('チームを切り替えでセッションが解除されオンボーディングに戻る', (tester) async {
    await pumpApp(
      tester,
      session: const TeamSession(teamId: 'ABCD1234', teamName: '〇〇高校', role: StaffRole.headCoach),
    );

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('チームを切り替え'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('抜ける'));
    await tester.pumpAndSettle();

    expect(find.text('ようこそ'), findsOneWidget);
    expect(app_main.currentTeamSession, isNull);
    expect(app_main.teamSetupComplete, isFalse);
  });
}
