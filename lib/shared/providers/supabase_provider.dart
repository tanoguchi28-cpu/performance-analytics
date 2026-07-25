import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase移行スキャフォールド用のクライアントプロバイダ。
///
/// `sports_medical/flutter_app`の`supabaseProvider`と同じ形。現時点では
/// `main()`で`Supabase.initialize()`を呼んでいないため、このプロバイダを
/// 実際に`watch`すると例外になる。`Supabase*Repository`群からのみ参照される
/// 想定で、アプリの他の箇所からは参照しないこと。
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
