import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/ability_category.dart';
import '../../../evaluation/domain/ability_profile.dart';

/// 複数グループ（学年別・ポジション別）の能力プロファイルを1つのレーダーチャートに
/// 重ねて表示し、グループ間の違いを比較できるようにする。
/// 全グループが揃って評価を持つカテゴリのみを軸として使う（軸数が3未満なら案内表示）。
class GroupAbilityRadarChart extends StatelessWidget {
  const GroupAbilityRadarChart({super.key, required this.profilesByLabel, this.size = 260});

  final Map<String, AbilityProfile> profilesByLabel;
  final double size;

  static const _palette = [Color(0xFFEA580C), Color(0xFF1E88E5), Color(0xFF43A047)];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (profilesByLabel.isEmpty) {
      return SizedBox(
        height: size,
        child: const Center(child: Text('データがありません')),
      );
    }

    final sharedCategories = AbilityCategory.values.where((c) {
      if (c == AbilityCategory.none) return false;
      return profilesByLabel.values.every((profile) {
        final score = profile.scores.where((s) => s.category == c).firstOrNull;
        return score != null && score.hasData;
      });
    }).toList();

    if (sharedCategories.length < 3) {
      return SizedBox(
        height: size,
        child: Center(
          child: Text(
            '全グループで比較可能な項目が3つ未満のため表示できません',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    final labels = profilesByLabel.keys.toList();

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              tickCount: 5,
              radarBorderData: BorderSide(color: cs.outlineVariant),
              gridBorderData: BorderSide(color: cs.outlineVariant, width: 1),
              tickBorderData: const BorderSide(color: Colors.transparent),
              ticksTextStyle: const TextStyle(fontSize: 0, color: Colors.transparent),
              titleTextStyle: Theme.of(context).textTheme.bodySmall,
              getTitle: (index, angle) => RadarChartTitle(text: sharedCategories[index].label),
              dataSets: [
                for (var i = 0; i < labels.length; i++)
                  RadarDataSet(
                    fillColor: _palette[i % _palette.length].withValues(alpha: 0.12),
                    borderColor: _palette[i % _palette.length],
                    borderWidth: 2,
                    entryRadius: 2.5,
                    dataEntries: [
                      for (final c in sharedCategories)
                        RadarEntry(
                          value: profilesByLabel[labels[i]]!.scores
                              .firstWhere((s) => s.category == c)
                              .score!,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: [
            for (var i = 0; i < labels.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 10, color: _palette[i % _palette.length]),
                  const SizedBox(width: 4),
                  Text(labels[i], style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
