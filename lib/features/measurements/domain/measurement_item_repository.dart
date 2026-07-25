import '../../../core/database/local_database.dart';

/// 測定項目マスタのデータアクセス抽象インターフェース。
abstract class MeasurementItemRepository {
  Future<List<MeasurementItem>> getAll({bool activeOnly = true});
  Future<MeasurementItem?> getByKey(String key);
  Future<String> create(MeasurementItemsCompanion companion);
  Future<void> update(String id, MeasurementItemsCompanion companion);
  Future<void> deactivate(String id);
}
