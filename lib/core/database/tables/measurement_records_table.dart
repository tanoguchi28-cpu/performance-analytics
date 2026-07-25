import 'package:drift/drift.dart';

import 'athletes_table.dart';
import 'measurement_items_table.dart';
import 'measurement_sessions_table.dart';

/// 選手×測定セッション×測定項目 の実測値1件。
/// 選手ID・測定日（セッション経由）をキーに全履歴を保持する。
class MeasurementRecords extends Table {
  TextColumn get id => text()();
  TextColumn get athleteId => text().references(Athletes, #id)();
  TextColumn get sessionId => text().references(MeasurementSessions, #id)();
  TextColumn get itemId => text().references(MeasurementItems, #id)();
  RealColumn get value => real()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {athleteId, sessionId, itemId},
      ];
}
