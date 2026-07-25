import '../../../core/database/local_database.dart';

/// 選手データアクセスの抽象インターフェース。
/// 現在は [LocalAthleteRepository] のみだが、将来Supabase実装に
/// 差し替える際もこのインターフェースは変更不要にする。
abstract class AthleteRepository {
  Future<List<Athlete>> getAll({bool activeOnly = true});
  Future<Athlete?> getById(String id);
  Future<String> create(AthletesCompanion companion);
  Future<void> update(String id, AthletesCompanion companion);
  Future<void> deactivate(String id);

  /// 選手を完全に削除する（誤登録の取り消し等）。所属する測定記録も合わせて
  /// 削除する。卒業・退部等の通常運用では[deactivate]（非表示化）を使うこと。
  Future<void> delete(String id);
}
