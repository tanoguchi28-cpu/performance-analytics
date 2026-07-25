import 'package:flutter/material.dart';

import '../../../../core/database/local_database.dart';
import '../../domain/dashboard_models.dart';

class AlertsCard extends StatelessWidget {
  const AlertsCard({
    super.key,
    required this.missingAthletes,
    required this.significantDeclines,
  });

  final List<Athlete> missingAthletes;
  final List<AthleteChange> significantDeclines;

  @override
  Widget build(BuildContext context) {
    final hasAlerts = missingAthletes.isNotEmpty || significantDeclines.isNotEmpty;
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasAlerts ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: hasAlerts ? const Color(0xFFF57C00) : cs.primary,
                ),
                const SizedBox(width: 8),
                Text('アラート', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            if (!hasAlerts)
              const Text('現在アラートはありません')
            else ...[
              if (missingAthletes.isNotEmpty) ...[
                Text(
                  '測定漏れ（${missingAthletes.length}名）',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(missingAthletes.map((a) => a.name).join('、')),
                const SizedBox(height: 12),
              ],
              if (significantDeclines.isNotEmpty) ...[
                Text(
                  '大きく低下した選手（${significantDeclines.length}名）',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                for (final c in significantDeclines)
                  Text('${c.athlete.name}: ${c.avgPercentChange.toStringAsFixed(1)}%'),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
