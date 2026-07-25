import 'package:drift/drift.dart';

import '../athletes_table.dart';

/// ウェアラブル端末（睡眠・HRV・安静時心拍等）連携のためのテーブル雛形。
/// **`AppDatabase`には未登録。**
///
/// 測定セッション（体力測定イベント）とは独立に、選手ごとの日次コンディション
/// データを時系列で保持する想定（[MeasurementRecords]とは別軸のデータ）。
/// [metricType]は将来的に固定enumへ寄せてもよいが、対応ウェアラブル機器や
/// 指標が確定していない現段階ではテキストで柔軟に受け付ける設計にしている
/// （[MeasurementItem]マスタと同様の「決め打ちしない」思想を踏襲）。
/// 詳細設計は docs/future_extensions.md を参照。
class WearableMetrics extends Table {
  TextColumn get id => text()();
  TextColumn get athleteId => text().references(Athletes, #id)();

  DateTimeColumn get recordedDate => dateTime()();

  /// 例: "hrv", "sleep_score", "resting_heart_rate", "recovery_score" 等。
  TextColumn get metricType => text()();
  RealColumn get value => real()();
  TextColumn get unit => text().nullable()();
  TextColumn get sourceDevice => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {athleteId, recordedDate, metricType},
      ];
}
