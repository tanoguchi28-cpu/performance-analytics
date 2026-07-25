import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/team_session/data/team_session_provider.dart';
import '../../features/team_session/domain/staff_role.dart';
import '../utils/responsive.dart';

class _NavDestination {
  const _NavDestination(this.path, this.icon, this.selectedIcon, this.label);

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _staffDestinations = [
  _NavDestination('/dashboard', Icons.dashboard_outlined, Icons.dashboard, 'ダッシュボード'),
  _NavDestination('/athletes', Icons.groups_outlined, Icons.groups, '選手'),
  _NavDestination('/measurements', Icons.rule_outlined, Icons.rule, '測定'),
  _NavDestination('/ranking', Icons.emoji_events_outlined, Icons.emoji_events, 'ランキング'),
  _NavDestination('/team-analysis', Icons.insights_outlined, Icons.insights, 'チーム分析'),
  _NavDestination('/settings', Icons.settings_outlined, Icons.settings, '設定'),
];

/// 選手ロールは自分の記録とチーム分析のみ閲覧可能なため、ナビゲーションもこの2項目に絞る。
const _playerDestinations = [
  _NavDestination('/my-report', Icons.badge_outlined, Icons.badge, '自分の記録'),
  _NavDestination('/team-analysis', Icons.insights_outlined, Icons.insights, 'チーム分析'),
];

/// デスクトップ/タブレットではNavigationRail、モバイルでは下部NavigationBarを
/// 同じルート定義から出し分けるレスポンシブなナビゲーションシェル。
/// ロールが選手の場合はナビゲーション項目自体を制限する。
class ScaffoldWithNav extends ConsumerWidget {
  const ScaffoldWithNav({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location, List<_NavDestination> destinations) {
    final index = destinations.indexWhere((d) => location.startsWith(d.path));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(teamSessionProvider);
    final destinations = session?.role == StaffRole.player ? _playerDestinations : _staffDestinations;

    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _indexForLocation(location, destinations);

    void onSelect(int index) => context.go(destinations[index].path);

    if (context.isCompact) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelect,
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelect,
            extended: context.isExpanded,
            labelType: context.isExpanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: [
              for (final d in destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
