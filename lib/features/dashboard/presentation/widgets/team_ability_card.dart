import 'package:flutter/material.dart';

import '../../../evaluation/domain/ability_profile.dart';
import '../../../../shared/widgets/ability_radar_chart.dart';

class TeamAbilityCard extends StatelessWidget {
  const TeamAbilityCard({super.key, required this.profile});

  final AbilityProfile profile;

  @override
  Widget build(BuildContext context) {
    final measured = [...profile.measuredScores]
      ..sort((a, b) => b.score!.compareTo(a.score!));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('チーム能力', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Center(child: AbilityRadarChart(profile: profile, size: 220)),
            const SizedBox(height: 12),
            if (measured.isNotEmpty) ...[
              _StrengthRow(
                label: 'チームの強み',
                text: '${measured.first.category.label}（偏差値相当 ${measured.first.roundedScore}）',
                color: const Color(0xFF2E7D32),
              ),
              if (measured.length > 1)
                _StrengthRow(
                  label: '改善ポイント',
                  text: '${measured.last.category.label}（偏差値相当 ${measured.last.roundedScore}）',
                  color: const Color(0xFFE53935),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StrengthRow extends StatelessWidget {
  const _StrengthRow({required this.label, required this.text, required this.color});

  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
