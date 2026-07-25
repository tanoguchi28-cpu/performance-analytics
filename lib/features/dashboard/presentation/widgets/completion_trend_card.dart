import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/dashboard_models.dart';

class CompletionTrendCard extends StatelessWidget {
  const CompletionTrendCard({super.key, required this.trend});

  final List<CompletionTrendPoint> trend;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('測定実施率の推移', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (trend.length < 2)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('推移を表示するには2回以上の測定セッションが必要です'),
              )
            else
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 1,
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          interval: 0.25,
                          getTitlesWidget: (value, meta) => Text('${(value * 100).round()}%'),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.round();
                            if (i < 0 || i >= trend.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                DateFormat('M/d').format(trend[i].measurementDate),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: cs.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: cs.primary.withValues(alpha: 0.15)),
                        spots: [
                          for (var i = 0; i < trend.length; i++)
                            FlSpot(i.toDouble(), trend[i].completionRate),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
