import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../features/evaluation/domain/ability_profile.dart';

/// 選手の6能力カテゴリ評価をレーダーチャートで表示する。
///
/// 軸は常に6カテゴリ全て固定表示する（未測定のカテゴリだけ軸ごと消えると
/// 選手間で形が比較しづらいため）。未測定カテゴリは値0として描画され、
/// 結果としてその方向だけ線がほぼ伸びない見た目になる。
///
/// 目盛りは常に0〜5固定にする。fl_chartのRadarChartは目盛りの最小/最大値を
/// 明示指定できず、渡した全データの実際の最小値・最大値から都度自動計算する
/// ため、素の実装だと選手やチームによって枠の大きさ・中心の意味が変わって
/// しまう。見た目には出ない透明な「番兵」データセット（全軸0・全軸5）を
/// 追加して最小値0・最大値5を強制し、[RadarChartData.isMinValueAtCenter]と
/// 組み合わせることで常に「中心=0、外周=5、目盛り1本=1点」に固定している。
class AbilityRadarChart extends StatelessWidget {
  const AbilityRadarChart({super.key, required this.profile, this.size = 260});

  final AbilityProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scores = profile.scores;

    if (profile.measuredScores.isEmpty) {
      return _Placeholder(size: size, message: '測定データがありません');
    }

    final zeroSentinel = RadarDataSet(
      fillColor: Colors.transparent,
      borderColor: Colors.transparent,
      borderWidth: 0,
      entryRadius: 0,
      dataEntries: scores.map((_) => const RadarEntry(value: 0)).toList(),
    );
    final maxSentinel = RadarDataSet(
      fillColor: Colors.transparent,
      borderColor: Colors.transparent,
      borderWidth: 0,
      entryRadius: 0,
      dataEntries: scores.map((_) => const RadarEntry(value: 5)).toList(),
    );

    // fl_chartの軸タイトルはCustomPaintの外側にクリップされずに描画されるため、
    // 2行のタイトルテキストがsize×sizeの範囲をはみ出して直下のウィジェット
    // （凡例など）と重なってしまう。radarRadiusはmin(width,height)/2*0.8で
    // 決まるため、横幅はsizeのまま高さだけ広げれば見た目のチャート半径を
    // 変えずに上下の食み出し分の安全マージンを確保できる。
    return SizedBox(
      width: size,
      height: size + 64,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 5,
          isMinValueAtCenter: true,
          titlePositionPercentageOffset: 0.12,
          radarBorderData: BorderSide(color: cs.outlineVariant),
          gridBorderData: BorderSide(color: cs.outlineVariant, width: 1),
          tickBorderData: const BorderSide(color: Colors.transparent),
          ticksTextStyle: const TextStyle(fontSize: 0, color: Colors.transparent),
          titleTextStyle: Theme.of(context).textTheme.bodySmall,
          getTitle: (index, angle) {
            final s = scores[index];
            return RadarChartTitle(
              text: s.category.label,
              children: [
                TextSpan(
                  text: s.hasData ? '\n${s.roundedScore}' : '\n未測定',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: s.hasData ? cs.primary : cs.outline,
                  ),
                ),
              ],
            );
          },
          dataSets: [
            zeroSentinel,
            maxSentinel,
            RadarDataSet(
              fillColor: cs.primary.withValues(alpha: 0.25),
              borderColor: cs.primary,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: scores.map((s) => RadarEntry(value: s.score ?? 0)).toList(),
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
