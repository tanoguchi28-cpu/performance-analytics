import 'package:drift/drift.dart';

/// 測定セッション（測定実施日）。チーム全体で1回の測定イベントを表す。
class MeasurementSessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get measurementDate => dateTime()();
  TextColumn get label => text().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
