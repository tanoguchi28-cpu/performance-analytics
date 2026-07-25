import '../../../core/database/local_database.dart';

/// 評価基準（新体力テスト等の得点表）のデータアクセス抽象インターフェース。
abstract class EvaluationCriteriaRepository {
  Future<List<EvaluationCriterion>> getCriteriaForItem(String itemKey);
  Future<List<ScoreBand>> getBands(String criteriaId);

  /// 実測値から5段階評価を算出する。該当する基準/バンドがなければ
  /// null（=「評価なし」。レーダーチャートには表示しない）。
  ///
  /// [position] が指定され、かつその項目にポジション別基準があれば
  /// それを優先し、無ければポジション共通の基準にフォールバックする。
  Future<int?> evaluate({
    required String itemKey,
    required double value,
    String? position,
  });

  /// 評価基準セットを新規作成する。[position]がnullなら「ポジション共通」。
  Future<String> createCriterion({
    required String itemKey,
    required String name,
    String? position,
  });

  /// 評価基準セットを削除する（所属する得点帯も合わせて削除する）。
  Future<void> deleteCriterion(String id);

  /// 得点帯を作成・更新する。[id]を指定すると更新、省略すると新規作成する。
  Future<String> upsertBand({
    String? id,
    required String criteriaId,
    required int score,
    double? minValue,
    double? maxValue,
  });

  Future<void> deleteBand(String id);
}
