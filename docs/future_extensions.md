# 将来拡張スキャフォールド: 動画・GPS・ウェアラブル連携

このドキュメントは、当初の仕様書に挙げられていた拡張項目のうち「動画分析」
「GPS」「ウェアラブル連携」について、データモデルの設計とテーブル雛形を
まとめたものです。**このスキャフォールドはテーブル定義（`Table`クラス）のみ
存在し、`lib/core/database/local_database.dart`の`@DriftDatabase(tables: [...])`
には未登録です。** そのためスキーマにもUIにも一切影響しません。

対応するテーブル雛形: `lib/core/database/tables/future/`
- `video_clips_table.dart` — `VideoClips`
- `gps_tracks_table.dart` — `GpsTracks` / `GpsPoints`
- `wearable_metrics_table.dart` — `WearableMetrics`

## 設計方針

既存の`MeasurementItem`マスタ方式（測定項目を決め打ちせずマスタテーブルで
管理する）と同じ思想を踏襲しつつ、これらの新機能は**単純な数値1件で表現
できないデータ**（動画ファイル、位置の時系列、日次コンディション指標）を
扱うため、`MeasurementRecords`には乗せず独立したテーブル群とする。

- 選手（`athleteId`）・測定セッション（`sessionId`、nullable）への紐付けは
  既存の`MeasurementRecords`と同じ外部キーパターンを踏襲し、選手個人ページ・
  チーム分析からの参照を将来追加しやすくする
- `WearableMetrics`は測定セッションに紐付かない日次データのため、
  セッションFKを持たせず`athleteId + recordedDate + metricType`で一意にする

## 各機能の実装時に追加が必要なもの（未着手）

### 動画分析（`VideoClips`）
- `AppDatabase`への登録・マイグレーション（`schemaVersion`インクリメント）
- 動画ファイルの実体保存先（ローカル: `path_provider`のドキュメントディレクトリ
  配下 / Supabase移行後: Supabase Storage）
- `lib/features/video_analysis/`feature一式（一覧・再生・選手/セッションへの
  紐付けUI）
- 既存の`image_picker`パッケージは静止画専用のため、動画選択には
  別途`file_picker`（既存依存を流用可）または動画専用ピッカーの検討が必要

### GPS連携（`GpsTracks` / `GpsPoints`）
- 対応GPS機器のエクスポート形式（CSV/FIT等）を読み込むインポーター
  （`lib/features/excel_import/`のExcelインポート実装がパーサ設計の参考になる）
- 地図表示ライブラリの選定（`google_maps_flutter`等、新規依存が必要になる
  見込み — 導入時は既存の「ライブラリは正当な理由がある場合のみ追加」方針に
  従い改めて検討する）
- `GpsPoints`はデータ量が大きくなるため、保持期間や間引き方針を別途設計する

### ウェアラブル連携（`WearableMetrics`）
- 対応端末（Apple Watch/Garmin/WHOOP等）ごとのデータ取得方法（HealthKit/
  Google Fit経由 or 手動CSVインポート）
- `metricType`の正式な値一覧の確定（現状はテキストで柔軟に受ける設計）
- ダッシュボード・選手個人ページへの表示（既存の`AbilityRadarChart`とは
  別軸の「コンディション」セクションとして追加するのが自然）

## スコープ外（今回のスキャフォールドに含まれない）

当初仕様書に列挙されていたその他の拡張項目（RPE、傷害管理、SOAP、栄養、
筋力測定、Force Plate、ジャンプマット）は今回のスキャフォールド対象外。
いずれも同じパターン（独立feature + 必要に応じた新規テーブル、既存の
選手・測定セッションへのFK紐付け）で追加できる設計になっている。
