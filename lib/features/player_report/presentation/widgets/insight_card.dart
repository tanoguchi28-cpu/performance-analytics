import 'package:flutter/material.dart';

import '../../../ai_insights/domain/athlete_insight.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight});

  final AthleteInsight insight;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI分析', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (!insight.hasData)
              const Text('測定データが不足しているため分析できません')
            else ...[
              _Section(
                title: '強み',
                icon: Icons.emoji_events_outlined,
                color: const Color(0xFF2E7D32),
                items: [for (final s in insight.strengths) '${s.category.label}（評価${s.roundedScore}）'],
              ),
              const SizedBox(height: 12),
              _Section(
                title: '改善点',
                icon: Icons.trending_up,
                color: const Color(0xFFE53935),
                items: [for (final w in insight.weaknesses) '${w.category.label}（評価${w.roundedScore}）'],
              ),
              if (insight.trainingSuggestions.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Section(
                  title: 'トレーニング提案',
                  icon: Icons.fitness_center,
                  color: Theme.of(context).colorScheme.primary,
                  items: insight.trainingSuggestions,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 4),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 2),
            child: Text('・$item'),
          ),
      ],
    );
  }
}
