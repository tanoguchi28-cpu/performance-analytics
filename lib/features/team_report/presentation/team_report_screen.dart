import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../core/services/pdf_report_service.dart';
import '../../../shared/widgets/ability_radar_chart.dart';
import '../../ai_insights/domain/athlete_insight.dart';
import '../../player_report/presentation/widgets/insight_card.dart';
import '../data/team_report_service.dart';
import '../domain/team_report_models.dart';
import 'widgets/comparison_table_card.dart';
import 'widgets/ranking_summary_card.dart';

/// A4印刷を意識したチームレポート。チーム能力・改善ポイント・ランキング・
/// 学年別/ポジション別/年度別比較をまとめて表示し、PDF出力できる。
class TeamReportScreen extends ConsumerWidget {
  const TeamReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(teamReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('チームレポート'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'PDF出力',
            onPressed: reportAsync.value == null ? null : () => _exportPdf(context, reportAsync.value!),
          ),
        ],
      ),
      body: reportAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(data: data),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('チーム能力', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          AbilityRadarChart(profile: data.teamAbilityProfile, size: 240),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InsightCard(insight: generateAthleteInsight(data.teamAbilityProfile)),
                  const SizedBox(height: 16),
                  RankingSummaryCard(
                    overallRanking: data.overallRanking,
                    items: data.items,
                    itemRankingsByItemId: data.itemRankingsByItemId,
                  ),
                  const SizedBox(height: 16),
                  ComparisonTableCard(title: 'ポジション別比較（平均値）', table: data.positionComparison),
                  const SizedBox(height: 16),
                  ComparisonTableCard(title: '年度別比較（平均値）', table: data.yearComparison),
                ],
              ),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('読み込みエラー: $e')),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, TeamReportData data) async {
    await Printing.layoutPdf(
      name: 'チームレポート',
      format: PdfPageFormat.a4,
      onLayout: (_) => PdfReportService.buildTeamReportPdf(data),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.data});

  final TeamReportData data;

  @override
  Widget build(BuildContext context) {
    final session = data.session;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('チームレポート', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    session == null
                        ? '測定データがありません'
                        : '測定日: ${DateFormat('yyyy/M/d').format(session.measurementDate)}'
                            '${session.label != null ? '（${session.label}）' : ''}',
                  ),
                  Text('登録選手数: ${data.athleteCount}名'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
