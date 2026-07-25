import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/stat_tile.dart';
import '../data/dashboard_data_service.dart';
import '../domain/dashboard_models.dart';
import 'widgets/alerts_card.dart';
import 'widgets/completion_trend_card.dart';
import 'widgets/improvement_ranking_card.dart';
import 'widgets/ranking_section_card.dart';
import 'widgets/team_ability_card.dart';

/// アプリを開いて最初に表示される画面。「チームの現状を5秒で把握できること」が目的。
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ダッシュボード')),
      body: dataAsync.when(
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardDataProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(summary: data.summary),
                const SizedBox(height: 16),
                TeamAbilityCard(profile: data.teamAbilityProfile),
                const SizedBox(height: 16),
                RankingSectionCard(rankings: data.rankings),
                const SizedBox(height: 16),
                ImprovementRankingCard(
                  topImproved: data.topImproved,
                  topDeclined: data.topDeclined,
                ),
                const SizedBox(height: 16),
                AlertsCard(
                  missingAthletes: data.missingAthletes,
                  significantDeclines: data.significantDeclines,
                ),
                const SizedBox(height: 16),
                CompletionTrendCard(trend: data.completionTrend),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('読み込みエラー: $e')),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        StatTile(
          label: '登録選手数',
          value: '${summary.athleteCount}名',
          icon: Icons.groups_outlined,
        ),
        StatTile(
          label: '最新測定日',
          value: summary.latestSessionDate == null
              ? '未実施'
              : DateFormat('yyyy/MM/dd').format(summary.latestSessionDate!),
          icon: Icons.event_outlined,
        ),
        StatTile(
          label: '測定実施率',
          value: '${(summary.completionRate * 100).round()}%',
          icon: Icons.fact_check_outlined,
        ),
        StatTile(
          label: '平均身長',
          value: summary.avgHeight == null ? '-' : '${summary.avgHeight!.toStringAsFixed(1)} cm',
          icon: Icons.height,
        ),
        StatTile(
          label: '平均体重',
          value: summary.avgWeight == null ? '-' : '${summary.avgWeight!.toStringAsFixed(1)} kg',
          icon: Icons.monitor_weight_outlined,
        ),
      ],
    );
  }
}
