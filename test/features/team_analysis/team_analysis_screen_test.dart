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
          AthletesCompanion.insert(id: 'a1', name: '横田向星', grade: 1, position: const Value('G')),
        );
    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'a2', name: '小森瑛太', grade: 2, position: const Value('F')),
        );
    await db.into(db.athletes).insert(
          AthletesCompanion.insert(id: 'a3', name: '山田太郎', grade: 3, position: const Value('C')),
        );

    const sessionId = 'session1';
    await db.into(db.measurementSessions).insert(
          MeasurementSessionsCompanion.insert(id: sessionId, measurementDate: DateTime(2026, 4, 1)),
        );

    final records = [
      ('r1', 'a1', 'vertical_jump', 65.0),
      ('r2', 'a2', 'vertical_jump', 55.0),
      ('r3', 'a3', 'vertical_jump', 45.0),
      ('r4', 'a1', 'three_quarter_sprint', 3.1),
      ('r5', 'a2', 'three_quarter_sprint', 3.4),
      ('r6', 'a3', 'three_quarter_sprint', 3.7),
    ];
    for (final (id, athleteId, itemKey, value) in records) {
      await db.into(db.measurementRecords).insert(
            MeasurementRecordsCompanion.insert(
              id: id,
              athleteId: athleteId,
              sessionId: sessionId,
              itemId: itemKey,
              value: value,
            ),
          );
    }
  });

  tearDown(() => db.close());

  testWidgets('分布・散布図/相関・チーム比較・年度比較の各タブが表示される', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PerformanceAnalyticsApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('チーム分析'));
    await tester.pumpAndSettle();

    // デフォルト選択は測定項目マスタの先頭=身長で、この項目には記録が無いため
    // 記録のある「垂直跳び」を選択してから各タブを確認する
    expect(find.text('測定項目'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('垂直跳び').last);
    await tester.pumpAndSettle();

    expect(find.text('分布'), findsOneWidget);
    expect(find.text('測定人数'), findsOneWidget);

    await tester.tap(find.text('散布図・相関'));
    await tester.pumpAndSettle();
    expect(find.textContaining('相関係数'), findsOneWidget);
    expect(find.text('全項目の相関ヒートマップ'), findsOneWidget);

    await tester.tap(find.text('チーム比較'));
    await tester.pumpAndSettle();
    expect(find.text('ポジション別平均'), findsOneWidget);

    await tester.tap(find.text('年度比較'));
    await tester.pumpAndSettle();
    expect(find.text('年度別平均'), findsOneWidget);
  });
}
