import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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
    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'a2', name: '小森瑛太', grade: 3, position: const Value('C')),
        );
    const sessionId = 'session1';
    await db.into(db.measurementSessions).insert(
          MeasurementSessionsCompanion.insert(id: sessionId, measurementDate: DateTime(2026, 4, 1)),
        );
    await db.into(db.measurementRecords).insert(
          MeasurementRecordsCompanion.insert(
            id: 'r1',
            athleteId: 'a1',
            sessionId: sessionId,
            itemId: 'vertical_jump',
            value: 65,
          ),
        );
    await db.into(db.measurementRecords).insert(
          MeasurementRecordsCompanion.insert(
            id: 'r2',
            athleteId: 'a2',
            sessionId: sessionId,
            itemId: 'vertical_jump',
            value: 50,
          ),
        );
  });

  tearDown(() => db.close());

  testWidgets('総合順位と項目別順位を切り替えて表示できる', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PerformanceAnalyticsApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('ランキング'));
    await tester.pumpAndSettle();

    expect(find.text('総合順位'), findsWidgets);
    expect(find.text('横田向星'), findsOneWidget);
    expect(find.text('小森瑛太'), findsOneWidget);

    // 項目別順位に切り替え、記録のある「垂直跳び」を選択する
    // (デフォルト選択は測定項目マスタの先頭=身長で、この項目には記録が無いため)
    await tester.tap(find.text('項目別順位'));
    await tester.pumpAndSettle();

    expect(find.text('測定項目'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('垂直跳び').last);
    await tester.pumpAndSettle();

    expect(find.text('横田向星'), findsOneWidget);

    // ポジションフィルタで C のみに絞る
    await tester.tap(find.widgetWithText(ChoiceChip, 'C'));
    await tester.pumpAndSettle();

    expect(find.text('小森瑛太'), findsOneWidget);
    expect(find.text('横田向星'), findsNothing);
  });
}
