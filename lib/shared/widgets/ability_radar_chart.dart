import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../features/evaluation/domain/ability_profile.dart';

/// 選手の6能力カテゴリ評価をレーダーチャートで表示する。
/// 未測定（評価なし）のカテゴリは軸ごと表示しない。
/// fl_chartのRadarChartは3軸未満を描画できないため、評価済みが2項目以下の
/// 場合はチャートの代わりに案内メッセージを表示する。
class AbilityRadarChart extends StatelessWidget {
  const AbilityRadarChart({super.key, required this.profile, this.size = 260});

  final AbilityProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final measured = profile.measuredScores;

    if (measured.isEmpty) {
      return _Placeholder(size: size, message: '測定データがありません');
    }
    if (measured.length < 3) {
      return _Placeholder(
        size: size,
        message: 'レーダーチャートの表示には3項目以上の評価が必要です\n（現在${measured.length}項目）',
      );
    }

    return SizedBox(
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
          getTitle: (index, angle) {
            final s = measured[index];
            return RadarChartTitle(
              text: '${s.category.label}\n${s.roundedScore}',
            );
          },
          dataSets: [
            RadarDataSet(
              fillColor: cs.primary.withValues(alpha: 0.25),
              borderColor: cs.primary,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: measured.map((s) => RadarEntry(value: s.score!)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size, required this.message});

  final double size;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.radar, size: 40, color: cs.outlineVariant),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
