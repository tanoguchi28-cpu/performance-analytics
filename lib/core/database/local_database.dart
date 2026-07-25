import 'package:drift/drift.dart';

import 'connection/connection_stub.dart'
    if (dart.library.io) 'connection/connection_io.dart';
import '../constants/ability_category.dart';
import '../constants/seed_evaluation_criteria.dart';
import '../constants/seed_measurement_items.dart';
import 'tables/athletes_table.dart';
import 'tables/evaluation_criteria_table.dart';
import 'tables/measurement_items_table.dart';
import 'tables/measurement_records_table.dart';
import 'tables/measurement_sessions_table.dart';

part 'local_database.g.dart';

@DriftDatabase(tables: [
  Athletes,
  MeasurementItems,
  MeasurementSessions,
  MeasurementRecords,
  EvaluationCriteria,
  ScoreBands,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// テスト用: `NativeDatabase.memory()` 等を直接注入するコンストラクタ。
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaults();
        },
      );

  /// 測定項目マスタ・評価基準の初期値を投入する（新規DB作成時のみ実行）。
  Future<void> _seedDefaults() async {
    await batch((batch) {
      batch.insertAll(measurementItems, defaultMeasurementItems);
      batch.insertAll(evaluationCriteria, defaultEvaluationCriteria);
      batch.insertAll(scoreBands, defaultScoreBands);
    });
  }
}

