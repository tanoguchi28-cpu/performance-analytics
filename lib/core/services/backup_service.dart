import 'dart:convert';
import 'dart:typed_data';

import '../database/local_database.dart';

/// 全テーブルをJSONにエクスポート/インポートするローカルバックアップ機能。
/// drift生成の`toJson()`/`fromJson()`/`toCompanion()`をそのまま利用し、
/// テーブル構造の変更に追従しやすくしている。
class BackupService {
  const BackupService._();

  static const _version = 1;

  static Future<Uint8List> exportToJson(AppDatabase db) async {
    final data = <String, dynamic>{
      'version': _version,
      'exportedAt': DateTime.now().toIso8601String(),
      'athletes': [for (final r in await db.select(db.athletes).get()) r.toJson()],
      'measurementItems': [for (final r in await db.select(db.measurementItems).get()) r.toJson()],
      'measurementSessions': [for (final r in await db.select(db.measurementSessions).get()) r.toJson()],
      'measurementRecords': [for (final r in await db.select(db.measurementRecords).get()) r.toJson()],
      'evaluationCriteria': [for (final r in await db.select(db.evaluationCriteria).get()) r.toJson()],
      'scoreBands': [for (final r in await db.select(db.scoreBands).get()) r.toJson()],
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(data)));
  }

  /// バックアップを復元する。既存データは全て削除して置き換える（取り消し不可）。
  static Future<void> importFromJson(AppDatabase db, Uint8List bytes) async {
    final data = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;

    List<Map<String, dynamic>> listOf(String key) =>
        (data[key] as List? ?? []).cast<Map<String, dynamic>>();

    await db.transaction(() async {
      // 子テーブルから先に削除する（外部キーの向き: records/scoreBands -> 親テーブル）。
      await db.delete(db.measurementRecords).go();
      await db.delete(db.scoreBands).go();
      await db.delete(db.measurementSessions).go();
      await db.delete(db.measurementItems).go();
      await db.delete(db.evaluationCriteria).go();
      await db.delete(db.athletes).go();

      for (final json in listOf('athletes')) {
        await db.into(db.athletes).insert(Athlete.fromJson(json).toCompanion(true));
      }
      for (final json in listOf('measurementItems')) {
        await db.into(db.measurementItems).insert(MeasurementItem.fromJson(json).toCompanion(true));
      }
      for (final json in listOf('measurementSessions')) {
        await db
            .into(db.measurementSessions)
            .insert(MeasurementSession.fromJson(json).toCompanion(true));
      }
      for (final json in listOf('evaluationCriteria')) {
        await db
            .into(db.evaluationCriteria)
            .insert(EvaluationCriterion.fromJson(json).toCompanion(true));
      }
      for (final json in listOf('scoreBands')) {
        await db.into(db.scoreBands).insert(ScoreBand.fromJson(json).toCompanion(true));
      }
      for (final json in listOf('measurementRecords')) {
        await db
            .into(db.measurementRecords)
            .insert(MeasurementRecord.fromJson(json).toCompanion(true));
      }
    });
  }
}
