import 'package:flutter/material.dart';

import '../../../../core/database/local_database.dart';
import '../../../../shared/widgets/player_avatar.dart';

class AthleteCard extends StatelessWidget {
  const AthleteCard({super.key, required this.athlete, required this.onTap});

  final Athlete athlete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              PlayerAvatar(photoPath: athlete.photoPath, radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      athlete.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (athlete.position != null) _Badge(text: athlete.position!),
                        if (athlete.jerseyNumber != null) ...[
                          const SizedBox(width: 6),
                          _Badge(text: '#${athlete.jerseyNumber}'),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: cs.onSecondaryContainer),
      ),
    );
  }
}
