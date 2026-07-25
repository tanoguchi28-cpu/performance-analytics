import 'package:drift/drift.dart';

import '../athletes_table.dart';
import '../measurement_sessions_table.dart';

/// 動画分析機能のためのテーブル雛形。**`AppDatabase`の`@DriftDatabase(tables: [...])`
/// には未登録**であり、現時点ではスキーマに存在しない（生成コードも作られない）。
///
/// フォームチェックや試合映像を選手・測定セッションに紐付けて保存する想定。
/// 実装時は以下を検討すること:
/// - 動画本体はアプリ内DBではなくファイルシステム/クラウドストレージ（Supabase
///   Storage等）に置き、[filePath]にはローカルパスまたは署名付きURLを保持する
/// - サムネイル生成・再生位置ブックマーク（フォームの気になる瞬間へのタイムスタンプ）
/// - 詳細設計は docs/future_extensions.md を参照
class VideoClips extends Table {
  TextColumn get id => text()();

  /// 特定選手のフォームチェック等。チーム全体の映像（試合等）ならnull。
  TextColumn get athleteId => text().nullable().references(Athletes, #id)();

  /// 特定の測定セッションに紐づく映像であればセット。
  TextColumn get sessionId => text().nullable().references(MeasurementSessions, #id)();

  TextColumn get filePath => text()();
  TextColumn get title => text().nullable()();
  DateTimeColumn get recordedAt => dateTime()();
  IntColumn get durationSeconds => integer().nullable()();

  /// 例: "フォーム分析", "試合", "リハビリ経過" 等のタグ（カンマ区切り、暫定）。
  TextColumn get tags => text().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
