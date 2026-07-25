// ignore_for_file: do_not_use_environment

/// Supabase移行スキャフォールド用の環境変数定義。
///
/// 現時点ではどこからも呼び出されていない（[Env.validate]は`main()`に未接続）。
/// 移行を実施する際は `sports_medical/flutter_app/lib/core/constants/env.dart` と
/// 同じ`--dart-define-from-file`方式で値を注入し、`main()`で`Env.validate()`と
/// `Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey)`を呼ぶ。
/// 詳細は `docs/supabase_migration.md` を参照。
class SupabaseEnv {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static void validate() {
    assert(
      supabaseUrl.isNotEmpty && supabaseUrl.startsWith('https://'),
      '\n\n[SupabaseEnv] SUPABASE_URL is not set.\n'
      'Run: flutter run --dart-define-from-file=.env.json\n',
    );
    assert(
      supabaseAnonKey.isNotEmpty,
      '\n\n[SupabaseEnv] SUPABASE_ANON_KEY is not set.\n'
      'Run: flutter run --dart-define-from-file=.env.json\n',
    );
  }
}
