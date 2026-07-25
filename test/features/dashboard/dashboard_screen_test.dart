import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/app.dart';
import 'package:performance_analytics/core/database/database_provider.dart';
import 'package:performance_analytics/core/database/local_database.dart';
import 'package:performance_analytics/main.dart' as app_main;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    app_main.teamSetupComplete = true;

    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'a1', name: '横田向星', grade: 2, position: const Value('G')),
        );
    final sessionId = 'session1';
    await db.into(db.measurementSessions).insert(
          MeasurementSessionsCompanion.insert(id: sessionId, measurementDate: DateTime(2026, 4, 1)),
        );
    await db.into(db.measurementRecords).insert(
          MeasurementRecordsCompanion.insert(
            id: 'rec1',
            athleteId: 'a1',
            sessionId: sessionId,
            itemId: 'vertical_jump',
            value: 65,
          ),
        );
  });

  tearDown(() => db.close());

  testWidgets('ダッシュボードが実データを反映して表示される', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PerformanceAnalyticsApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ダッシュボード'), findsWidgets); // AppBarタイトル+ナビ両方に出るため
    expect(find.text('1名'), findsOneWidget); // 登録選手数
    expect(find.text('チーム能力'), findsOneWidget);
    expect(find.text('種目別ランキング TOP5'), findsOneWidget);
    expect(find.textContaining('横田向星'), findsWidgets); // 垂直跳びランキング・測定漏れアラートに登場
    expect(find.text('アラート'), findsOneWidget);
    expect(find.text('測定実施率の推移'), findsOneWidget);
  });
}
