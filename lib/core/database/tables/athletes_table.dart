import 'package:drift/drift.dart';

class Athletes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kana => text().nullable()();
  IntColumn get grade => integer()();
  TextColumn get position => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get jerseyNumber => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// コーチが自由記述するコメント（選手個人ページで編集）。
  TextColumn get coachComment => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
