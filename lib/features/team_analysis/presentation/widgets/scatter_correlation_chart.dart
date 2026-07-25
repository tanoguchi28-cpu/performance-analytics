import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/team_analysis_models.dart';

/// 2測定項目の散布図と、選手名ラベル付きツールチップを表示する。
class ScatterCorrelationChart extends StatelessWidget {
  const ScatterCorrelationChart({
    super.key,
    required this.points,
    required this.xLabel,
    required this.yLabel,
  });

  final List<AthletePoint> points;
  final String xLabel;
  final String yLabel;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('両項目を測定している選手がいません')),
      );
    }

    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 260,
      child: ScatterChart(
        ScatterChartData(
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: true, border: Border.all(color: cs.outlineVariant)),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              axisNameWidget: Text(yLabel, style: const TextStyle(fontSize: 11)),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) =>
                    Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 9)),
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: Text(xLabel, style: const TextStyle(fontSize: 11)),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) =>
                    Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 9)),
              ),
            ),
          ),
          scatterTouchData: ScatterTouchData(
            touchTooltipData: ScatterTouchTooltipData(
              getTooltipItems: (spot) {
                final i = points.indexWhere((p) => p.x == spot.x && p.y == spot.y);
                final name = i == -1 ? '' : points[i].athlete.name;
                return ScatterTooltipItem(
                  '$name\n(${spot.x.toStringAsFixed(1)}, ${spot.y.toStringAsFixed(1)})',
                  textStyle: const TextStyle(color: Colors.white, fontSize: 11),
                );
              },
            ),
          ),
          scatterSpots: [
            for (final p in points)
              ScatterSpot(
                p.x,
                p.y,
                dotPainter: FlDotCirclePainter(radius: 6, color: cs.primary),
              ),
          ],
        ),
      ),
    );
  }
}
