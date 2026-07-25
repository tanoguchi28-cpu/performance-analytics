import 'package:drift/drift.dart';

import '../../constants/ability_category.dart';

/// 測定項目マスタ。固定実装せず、このテーブル経由で項目の追加・削除・並び替えを行う。
class MeasurementItems extends Table {
  TextColumn get id => text()();
  TextColumn get key => text().unique()();
  TextColumn get name => text()();
  TextColumn get unit => text()();
  BoolColumn get higherIsBetter => boolean().withDefault(const Constant(true))();
  TextColumn get abilityCategory => textEnum<AbilityCategory>()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
