import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../team_session/data/team_session_provider.dart';

/// 設定のハブ画面。測定項目・評価基準・チーム設定・バックアップの各画面への導線。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('チームから抜けますか？'),
        content: const Text('この端末のチーム参加情報を削除し、初期セットアップ画面に戻ります。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('抜ける')),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(teamSessionProvider.notifier).clearSession();
    if (context.mounted) context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(teamSessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (session != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.teamName, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'チームID: ${session.teamId} / ${session.role.label}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          _SettingsTile(
            icon: Icons.straighten_outlined,
            title: '測定項目管理',
            subtitle: '測定項目の追加・編集・有効/無効の切り替え',
            onTap: () => context.push('/settings/measurement-items'),
          ),
          _SettingsTile(
            icon: Icons.rule_outlined,
            title: '評価基準設定',
            subtitle: '項目ごとの5段階評価の得点帯（ポジション別/共通）',
            onTap: () => context.push('/settings/evaluation-criteria'),
          ),
          _SettingsTile(
            icon: Icons.groups_outlined,
            title: 'チーム設定',
            subtitle: 'チーム名の変更',
            onTap: () => context.push('/settings/team'),
          ),
          if (session == null)
            _SettingsTile(
              icon: Icons.backup_outlined,
              title: 'データバックアップ',
              subtitle: '全データのエクスポート・インポート',
              onTap: () => context.push('/settings/backup'),
            ),
          if (session != null) ...[
            const Divider(height: 32),
            _SettingsTile(
              icon: Icons.logout,
              title: 'チームを切り替え',
              subtitle: '別のチームIDで参加し直す・チームから抜ける',
              onTap: () => _confirmSignOut(context, ref),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
