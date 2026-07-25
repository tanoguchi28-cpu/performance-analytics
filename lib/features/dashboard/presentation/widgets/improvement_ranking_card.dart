import 'package:flutter/material.dart';

import '../../domain/dashboard_models.dart';

class ImprovementRankingCard extends StatelessWidget {
  const ImprovementRankingCard({
    super.key,
    required this.topImproved,
    required this.topDeclined,
  });

  final List<AthleteChange> topImproved;
  final List<AthleteChange> topDeclined;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('前回比 改善ランキング', style: Theme.of(context).textTheme.titleMedium),
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
