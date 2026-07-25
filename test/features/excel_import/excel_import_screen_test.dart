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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    app_main.teamSetupComplete = true;
  });

  tearDown(() => db.close());

  testWidgets(
    '測定タブからExcelインポート画面を開ける',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const PerformanceAnalyticsApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('測定'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.upload_file_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Excelインポート'), findsOneWidget);
      expect(find.textContaining('ファイル選択'), findsOneWidget);
      expect(find.textContaining('ファイルを選択'), findsOneWidget);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
