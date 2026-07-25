import 'package:flutter/material.dart';

import '../../../../core/database/local_database.dart';
import '../../../../shared/widgets/stat_tile.dart';
import '../../../analytics/domain/statistics_calculator.dart';
import '../../domain/team_analysis_calculator.dart';
import '../../domain/team_analysis_models.dart';
import 'box_plot_chart.dart';
import 'histogram_chart.dart';

/// 選択中の測定項目について、分布の統計量・ヒストグラム・ポジション別の
/// 箱ひげ図を表示するタブ。
class DistributionTab extends StatelessWidget {
  const DistributionTab({super.key, required this.data, required this.item});

  final TeamAnalysisData data;
  final MeasurementItem item;

  @override
  Widget build(BuildContext context) {
    final records = data.selectedSessionRecords.where((r) => r.itemId == item.id).toList();
    final athleteById = {for (final a in data.athletes) a.id: a};
    final values = records.map((r) => r.value).toList();

    if (values.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: Text('このセッションには記録がありません')),
      );
    }

    final mean = StatisticsCalculator.mean(values);
    final median = StatisticsCalculator.median(values);
    final stddev = StatisticsCalculator.standardDeviation(values);
    final bins = TeamAnalysisCalculator.histogram(values);

    final positionGroups = _boxPlotsByGroup(
      records: records,
      athleteById: athleteById,
      groupKey: (a) => a.position,
      sortOrder: const ['G', 'F', 'C'],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              StatTile(label: '平均', value: '${mean.toStringAsFixed(1)}${item.unit}', icon: Icons.functions),
              StatTile(label: '中央値', value: '${median.toStringAsFixed(1)}${item.unit}', icon: Icons.linear_scale),
              StatTile(label: '標準偏差', value: stddev.toStringAsFixed(2), icon: Icons.ssid_chart),
              StatTile(label: '測定人数', value: '${values.length}名', icon: Icons.groups_outlined),
            ],
          ),
          const SizedBox(height: 20),
          Text('ヒストグラム', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: HistogramChart(bins: bins, unit: item.unit),
            ),
          ),
          const SizedBox(height: 20),
          Text('ポジション別の分布（箱ひげ図）', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BoxPlotChart(groups: positionGroups, unit: item.unit),
            ),
          ),
        ],
      ),
    );
  }

  List<GroupBoxPlot> _boxPlotsByGroup({
    required List<MeasurementRecord> records,
    required Map<String, Athlete> athleteById,
    required String? Function(Athlete) groupKey,
    required List<String> sortOrder,
  }) {
    final valuesByGroup = <String, List<double>>{};
    for (final record in records) {
      final athlete = athleteById[record.athleteId];
      if (athlete == null) continue;
      final key = groupKey(athlete);
      if (key == null) continue;
      valuesByGroup.putIfAbsent(key, () => []).add(record.value);
    }

    final keys = valuesByGroup.keys.toList()
      ..sort((a, b) {
        final ia = sortOrder.indexOf(a);
        final ib = sortOrder.indexOf(b);
        if (ia == -1 && ib == -1) return a.compareTo(b);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia.compareTo(ib);
      });

    return [
      for (final key in keys)
        GroupBoxPlot(
          label: key,
          stats: TeamAnalysisCalculator.boxPlot(valuesByGroup[key]!)!,
          count: valuesByGroup[key]!.length,
        ),
    ];
  }
}
