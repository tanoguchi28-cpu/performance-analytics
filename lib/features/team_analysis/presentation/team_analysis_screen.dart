import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/local_database.dart';
import '../data/team_analysis_service.dart';
import 'widgets/distribution_tab.dart';
import 'widgets/group_comparison_tab.dart';
import 'widgets/scatter_correlation_tab.dart';
import 'widgets/year_comparison_tab.dart';

/// チーム分析画面。分布・散布図/相関・チーム比較・年度比較の4タブで構成する。
class TeamAnalysisScreen extends ConsumerStatefulWidget {
  const TeamAnalysisScreen({super.key});

  @override
  ConsumerState<TeamAnalysisScreen> createState() => _TeamAnalysisScreenState();
}

class _TeamAnalysisScreenState extends ConsumerState<TeamAnalysisScreen> {
  String? _sessionId;
  String? _itemId;

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(teamAnalysisDataProvider(sessionId: _sessionId));

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('チーム分析'),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'チームレポート（PDF出力）',
              onPressed: () => context.push('/team-analysis/report'),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '分布'),
              Tab(text: '散布図・相関'),
              Tab(text: 'チーム比較'),
              Tab(text: '年度比較'),
            ],
          ),
        ),
        body: dataAsync.when(
          data: (data) {
            if (data.selectedSession == null) {
              return const Center(child: Text('測定データがありません'));
            }

            final items = data.items;
            _itemId ??= items.isEmpty ? null : items.first.id;
            final selectedItem = items.where((i) => i.id == _itemId).firstOrNull;

            return Column(
              children: [
                _SessionAndItemSelector(
                  sessions: data.sessions,
                  selectedSessionId: data.selectedSession!.id,
                  onSessionChanged: (id) => setState(() => _sessionId = id),
                  items: items,
                  selectedItemId: _itemId,
                  onItemChanged: (id) => setState(() => _itemId = id),
                ),
                Expanded(
                  child: selectedItem == null
                      ? const Center(child: Text('測定項目がありません'))
                      : TabBarView(
                          children: [
                            DistributionTab(data: data, item: selectedItem),
                            ScatterCorrelationTab(data: data),
                            GroupComparisonTab(data: data, item: selectedItem),
                            YearComparisonTab(data: data, item: selectedItem),
                          ],
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(child: Text('読み込みエラー: $e')),
        ),
      ),
    );
  }
}

class _SessionAndItemSelector extends StatelessWidget {
  const _SessionAndItemSelector({
    required this.sessions,
    required this.selectedSessionId,
    required this.onSessionChanged,
    required this.items,
    required this.selectedItemId,
    required this.onItemChanged,
  });

  final List<MeasurementSession> sessions;
  final String selectedSessionId;
  final ValueChanged<String?> onSessionChanged;
  final List<MeasurementItem> items;
  final String? selectedItemId;
  final ValueChanged<String?> onItemChanged;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/M/d');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: selectedSessionId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: '測定セッション'),
              items: [
                for (final s in sessions)
                  DropdownMenuItem(
                    value: s.id,
                    child: Text(s.label ?? dateFormat.format(s.measurementDate)),
                  ),
              ],
              onChanged: onSessionChanged,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: selectedItemId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: '測定項目'),
              items: [
                for (final i in items) DropdownMenuItem(value: i.id, child: Text(i.name)),
              ],
              onChanged: onItemChanged,
            ),
          ),
        ],
      ),
    );
  }
}
