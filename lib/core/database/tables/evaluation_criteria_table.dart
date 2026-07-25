import 'package:drift/drift.dart';

/// 評価基準セット（例: 「高校男子 基準」）。measurement_item.key単位で紐付く。
/// 将来的に競技・カテゴリ・性別・年齢別に複数セットを共存させられる。
@DataClassName('EvaluationCriterion')
class EvaluationCriteria extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get itemKey => text()();
  TextColumn get gender => text().nullable()();
  IntColumn get ageGroupMin => integer().nullable()();
  IntColumn get ageGroupMax => integer().nullable()();

  /// ポジション別に基準値が異なる項目向け（例: G/F/C）。
  /// nullは「ポジション共通」を意味する。
  TextColumn get position => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 評価基準1セットに属する5段階の得点帯（min <= value <= max → score）。
class ScoreBands extends Table {
  TextColumn get id => text()();
  TextColumn get criteriaId => text().references(EvaluationCriteria, #id)();
  RealColumn get minValue => real().nullable()();
  RealColumn get maxValue => real().nullable()();
  IntColumn get score => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
