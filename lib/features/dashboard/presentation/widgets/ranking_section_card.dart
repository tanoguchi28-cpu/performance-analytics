import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/dashboard_models.dart';

class RankingSectionCard extends StatelessWidget {
  const RankingSectionCard({super.key, required this.rankings});

  final List<RankingSection> rankings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('種目別ランキング TOP5', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (rankings.isEmpty)
              const Text('測定データがありません')
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [for (final section in rankings) _RankingList(section: section)],
              ),
          ],
        ),
      ),
    );
  }
}

class _RankingList extends StatelessWidget {
  const _RankingList({required this.section});

  final RankingSection section;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  section.itemName,
                  style: Theme.of(context).textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (section.measurementDate != null) ...[
                const SizedBox(width: 6),
                Text(
                  '(${DateFormat('M/d').format(section.measurementDate!)})',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          if (section.entries.isEmpty)
            Text('データなし', style: Theme.of(context).textTheme.bodySmall)
          else
            for (final entry in section.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        '${entry.rank}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: entry.rank == 1 ? cs.primary : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: Text(entry.athlete.name, overflow: TextOverflow.ellipsis)),
                    Text('${entry.value} ${section.unit}'),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
