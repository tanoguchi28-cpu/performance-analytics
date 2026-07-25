import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/team_analysis_models.dart';

/// 学年別・ポジション別・年度別など、グループごとの平均値を棒グラフで比較する。
class GroupBarChart extends StatelessWidget {
  const GroupBarChart({super.key, required this.groups, required this.unit});

  final List<GroupAverage> groups;
  final String unit;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('データがありません')),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final maxValue = groups.map((g) => g.average).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxValue <= 0 ? 1 : maxValue * 1.2,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) =>
                    Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 9)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i < 0 || i >= groups.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${groups[i].label}\n(n=${groups[i].count})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)}$unit',
                const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < groups.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: groups[i].average,
                    color: cs.primary,
                    width: 36,
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
