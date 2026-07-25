import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/local_database.dart';
import '../../domain/player_report_models.dart';

/// 選手個人の測定項目ごとの推移グラフ。項目をドロップダウンで切り替える。
class PlayerTrendChart extends StatefulWidget {
  const PlayerTrendChart({
    super.key,
    required this.items,
    required this.historyByItemKey,
  });

  final List<MeasurementItem> items;
  final Map<String, List<TrendPoint>> historyByItemKey;

  @override
  State<PlayerTrendChart> createState() => _PlayerTrendChartState();
}

class _PlayerTrendChartState extends State<PlayerTrendChart> {
  String? _selectedKey;

  @override
  Widget build(BuildContext context) {
    final availableKeys = widget.items
        .map((i) => i.key)
        .where((key) => (widget.historyByItemKey[key]?.length ?? 0) >= 2)
        .toList();
    _selectedKey ??= availableKeys.isEmpty ? null : availableKeys.first;

    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('推移グラフ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (availableKeys.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('推移を表示するには同じ項目を2回以上測定している必要があります'),
              )
            else ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedKey,
                isExpanded: true,
                decoration: const InputDecoration(labelText: '測定項目'),
                items: [
                  for (final key in availableKeys)
                    DropdownMenuItem(
                      value: key,
                      child: Text(widget.items.firstWhere((i) => i.key == key).name),
                    ),
                ],
                onChanged: (v) => setState(() => _selectedKey = v),
              ),
              const SizedBox(height: 12),
              _buildChart(context, cs),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, ColorScheme cs) {
    final item = widget.items.firstWhere((i) => i.key == _selectedKey);
    final points = widget.historyByItemKey[_selectedKey]!;
    final values = points.map((p) => p.value).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.15 + 0.01;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toStringAsFixed(1)}${item.unit}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i < 0 || i >= points.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('M/d').format(points[i].date),
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
                for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
