import 'package:drift/drift.dart';

import '../athletes_table.dart';
import '../measurement_sessions_table.dart';

/// GPS/位置トラッキング機能のためのテーブル雛形。**`AppDatabase`には未登録。**
///
/// 1回の練習・試合の走行データを[GpsTracks]に1件、そのGPSサンプル点列を
/// [GpsPoints]に多数、という構成（GPSベスト機器のログ取り込みを想定）。
/// 詳細設計は docs/future_extensions.md を参照。
class GpsTracks extends Table {
  TextColumn get id => text()();
  TextColumn get athleteId => text().references(Athletes, #id)();
  TextColumn get sessionId => text().nullable().references(MeasurementSessions, #id)();

  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  /// 集計値（生ポイントから再計算可能だが、表示高速化のため保持）。
  RealColumn get totalDistanceMeters => real().nullable()();
  RealColumn get maxSpeedKmh => real().nullable()();
  IntColumn get sprintCount => integer().nullable()();

  TextColumn get sourceDevice => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// [GpsTracks]1件に属する生の位置サンプル。データ量が大きくなるため
/// 実装時はバッチ取り込み・間引き（例: 1秒間隔）を検討する。
class GpsPoints extends Table {
  TextColumn get id => text()();
  TextColumn get trackId => text().references(GpsTracks, #id)();

  DateTimeColumn get timestamp => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get speedKmh => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
