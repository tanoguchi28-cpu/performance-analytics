import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants/supabase_env.dart';
import 'features/team_session/data/team_session_storage.dart';
import 'features/team_session/domain/team_session.dart';

/// チーム初期セットアップ完了フラグ（ルーターが同期アクセス用）
bool teamSetupComplete = false;

/// チーム共有モードのセッション（ルーターが同期アクセス用）。
/// nullの場合は従来通りローカル専用モードで動作する。
TeamSession? currentTeamSession;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  teamSetupComplete = prefs.getBool('team_setup_complete') ?? false;
  currentTeamSession = TeamSessionStorage(prefs).read();

  if (SupabaseEnv.supabaseUrl.isNotEmpty) {
    SupabaseEnv.validate();
    await Supabase.initialize(
      url: SupabaseEnv.supabaseUrl,
      publishableKey: SupabaseEnv.supabaseAnonKey,
    );
    try {
      await Supabase.instance.client.auth.signInAnonymously();
    } catch (e) {
      // 匿名サインインが失敗しても起動自体は継続する。チーム作成/参加時の
      // API呼び出しがエラーとして表面化し、オンボーディング画面のエラー表示で
      // ユーザーに伝わる（未接続時に無反応でクラッシュするより良い）。
      debugPrint('Supabase anonymous sign-in failed: $e');
    }
  }

  runApp(const ProviderScope(child: PerformanceAnalyticsApp()));
}
