import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/dashboard_models.dart';

class ImprovementRankingCard extends StatelessWidget {
  const ImprovementRankingCard({
    super.key,
    required this.topImproved,
    required this.topDeclined,
    this.previousDate,
    this.latestDate,
  });

  final List<AthleteChange> topImproved;
  final List<AthleteChange> topDeclined;

  /// 比較元/比較先の測定日。両方揃っていればヘッダーに「前回比」の
  /// 対象期間として表示する（何回目の測定同士の比較か分かるように）。
  final DateTime? previousDate;
  final DateTime? latestDate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateRange = (previousDate != null && latestDate != null)
        ? '${DateFormat('M/d').format(previousDate!)} → ${DateFormat('M/d').format(latestDate!)}'
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    '前回比 改善ランキング',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (dateRange != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    dateRange,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (topImproved.isEmpty && topDeclined.isEmpty)
              const Text('前回との比較データがありません')
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _ChangeList(
                    title: '向上 TOP10',
                    changes: topImproved,
                    color: const Color(0xFF2E7D32),
                  ),
                  _ChangeList(
                    title: '低下 TOP10',
                    changes: topDeclined,
                    color: const Color(0xFFE53935),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ChangeList extends StatelessWidget {
  const _ChangeList({required this.title, required this.changes, required this.color});

  final String title;
  final List<AthleteChange> changes;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          if (changes.isEmpty)
            Text('データなし', style: Theme.of(context).textTheme.bodySmall)
          else
            for (final c in changes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(child: Text(c.athlete.name, overflow: TextOverflow.ellipsis)),
                    Text(
                      '${c.avgPercentChange >= 0 ? '+' : ''}${c.avgPercentChange.toStringAsFixed(1)}%',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
