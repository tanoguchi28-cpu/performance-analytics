import '../../../core/database/local_database.dart';

/// 測定セッション（測定実施日）と実測値のデータアクセス抽象インターフェース。
/// 履歴管理のキーは 選手ID + セッションの測定日 。
abstract class MeasurementRepository {
  Future<List<MeasurementSession>> getSessions();
  Future<MeasurementSession?> getSession(String id);

  Future<String> createSession({
    required DateTime measurementDate,
    String? label,
    String? note,
  });

  /// 既存セッションの測定日・ラベル・メモを更新する。
  Future<void> updateSession({
    required String id,
    required DateTime measurementDate,
    String? label,
    String? note,
  });

  /// 測定セッションを削除する。所属する全選手・全項目の記録もまとめて削除する
  /// （Excelインポートを丸ごとやり直したい場合等に使う）。この操作は取り消せない。
  Future<void> deleteSession(String id);

  /// 同一(athleteId, sessionId, itemId)が既にあれば値を上書きする。
  Future<void> upsertRecord({
    required String athleteId,
    required String sessionId,
    required String itemId,
    required double value,
  });

  /// 指定の(athleteId, sessionId, itemId)の記録を削除する。誤入力の取り消し用。
  /// 該当する記録が無ければ何もしない。
  Future<void> deleteRecord({
    required String athleteId,
    required String sessionId,
    required String itemId,
  });

  /// 指定選手の全履歴（全セッション・全項目）を測定日昇順で取得。
  Future<List<MeasurementRecord>> getRecordsForAthlete(String athleteId);

  Future<List<MeasurementRecord>> getRecordsForSession(String sessionId);
}
