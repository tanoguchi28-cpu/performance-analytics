import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../core/services/pdf_report_service.dart';
import '../../../shared/widgets/ability_radar_chart.dart';
import '../../../shared/widgets/player_avatar.dart';
import '../data/player_report_service.dart';
import '../domain/player_report_models.dart';
import 'widgets/coach_comment_card.dart';
import 'widgets/insight_card.dart';
import 'widgets/player_results_table.dart';
import 'widgets/player_trend_chart.dart';

/// A4印刷を意識した選手個人ページ。プロフィール・レーダー・測定結果・推移・
/// AI分析（強み/改善点/トレーニング提案）・コーチコメントをまとめて表示する。
class PlayerReportScreen extends ConsumerWidget {
  const PlayerReportScreen({super.key, required this.athleteId});

  final String athleteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(playerReportProvider(athleteId: athleteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('選手ページ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'PDF出力',
            onPressed: reportAsync.value == null
                ? null
                : () => _exportPdf(context, reportAsync.value!),
          ),
        ],
      ),
      body: reportAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHeader(data: data),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('能力レーダー', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          AbilityRadarChart(profile: data.abilityProfile, size: 240),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PlayerResultsTable(results: data.results),
                  const SizedBox(height: 16),
                  PlayerTrendChart(
                    items: [for (final r in data.results) r.item],
                    historyByItemKey: data.historyByItemKey,
                  ),
                  const SizedBox(height: 16),
                  InsightCard(insight: data.insight),
                  const SizedBox(height: 16),
                  CoachCommentCard(athlete: data.athlete),
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

  Future<void> _exportPdf(BuildContext context, PlayerReportData data) async {
    await Printing.layoutPdf(
      name: '${data.athlete.name}_選手ページ',
      format: PdfPageFormat.a4,
      onLayout: (_) => PdfReportService.buildPlayerReportPdf(data),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.data});

  final PlayerReportData data;

  @override
  Widget build(BuildContext context) {
    final athlete = data.athlete;
    final ranking = data.overallRanking;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlayerAvatar(photoPath: athlete.photoPath, radius: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(athlete.name, style: Theme.of(context).textTheme.headlineSmall),
                  if (athlete.kana != null)
                    Text(athlete.kana!, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (athlete.position != null) Text(athlete.position!),
                      if (athlete.jerseyNumber != null) Text('#${athlete.jerseyNumber}'),
                      if (athlete.birthDate != null)
                        Text('${DateFormat('yyyy/MM/dd').format(athlete.birthDate!)}生'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (ranking != null)
                    Text(
                      '総合順位: ${ranking.rank}位 / ${data.overallRankingTeamSize}人中'
                      '（偏差値相当 ${ranking.averageDeviationScore.toStringAsFixed(1)}）',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    )
                  else
                    const Text('総合順位: データなし'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
