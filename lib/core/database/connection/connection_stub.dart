import 'package:drift/drift.dart';

/// Web向けスタブ。
///
/// ローカル専用モード（`Local*Repository`）は`dart:io`前提のSQLiteを使うため
/// Web上では動作させない。チーム共有モードのユーザーは常にSupabase経由の
/// リポジトリを使うため（`currentTeamSession`が非nullの間は`appDatabaseProvider`
/// 自体が参照されない）、このスタブが実際にクエリされることはない想定。
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    throw UnsupportedError(
      'ローカル専用モードはWeb版では利用できません。チームIDを入力してチームに参加してください。',
    );
  });
}
