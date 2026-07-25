import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/team_analysis_models.dart';

/// 測定値の分布を棒グラフで表示するヒストグラム。
class HistogramChart extends StatelessWidget {
  const HistogramChart({super.key, required this.bins, required this.unit});

  final List<HistogramBin> bins;
  final String unit;

  @override
  Widget build(BuildContext context) {
    if (bins.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('データがありません')),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final maxCount = bins.map((b) => b.count).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: (maxCount + 1).toDouble(),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, meta) =>
                    Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i < 0 || i >= bins.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      bins[i].from.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 9),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < bins.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: bins[i].count.toDouble(),
                    color: cs.primary,
                    width: 22,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
