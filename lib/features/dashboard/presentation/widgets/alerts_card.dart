import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/local_database.dart';
import '../../domain/dashboard_models.dart';

class AlertsCard extends StatelessWidget {
  const AlertsCard({
    super.key,
    required this.missingAthletes,
    required this.significantDeclines,
    this.previousDate,
    this.latestDate,
  });

  final List<Athlete> missingAthletes;
  final List<AthleteChange> significantDeclines;

  /// 「大きく低下した選手」の比較元/比較先の測定日。
  final DateTime? previousDate;
  final DateTime? latestDate;

  @override
  Widget build(BuildContext context) {
    final hasAlerts = missingAthletes.isNotEmpty || significantDeclines.isNotEmpty;
    final cs = Theme.of(context).colorScheme;
    final count = missingAthletes.length + significantDeclines.length;

    final headerIcon = Icon(
      hasAlerts ? Icons.warning_amber_rounded : Icons.check_circle_outline,
      color: hasAlerts ? const Color(0xFFF57C00) : cs.primary,
    );

    // アラートは常時確認するものではないため、既定では折りたたんでおき、
    // 件数バッジをタップすれば詳細が開く形にする。0件の場合は開く意味が
    // 無いので、これまで通り静的な行のみ表示する。
    if (!hasAlerts) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              headerIcon,
              const SizedBox(width: 8),
              Text('アラート', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '現在アラートはありません',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: headerIcon,
        title: Text('アラート', style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text('タップして$count件の詳細を表示'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (missingAthletes.isNotEmpty) ...[
            Text(
              '測定漏れ（${missingAthletes.length}名）',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(missingAthletes.map((a) => a.name).join('、')),
            const SizedBox(height: 12),
          ],
          if (significantDeclines.isNotEmpty) ...[
            Row(
              children: [
                Flexible(
                  child: Text(
                    '大きく低下した選手（${significantDeclines.length}名）',
                    style: Theme.of(context).textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (previousDate != null && latestDate != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('M/d').format(previousDate!)} → ${DateFormat('M/d').format(latestDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
            for (final c in significantDeclines)
              Text('${c.athlete.name}: ${c.avgPercentChange.toStringAsFixed(1)}%'),
          ],
        ],
      ),
    );
  }
}
