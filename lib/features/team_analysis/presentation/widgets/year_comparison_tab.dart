import 'package:flutter/material.dart';

import '../../../../core/database/local_database.dart';
import '../../domain/team_analysis_calculator.dart';
import '../../domain/team_analysis_models.dart';
import 'group_bar_chart.dart';

/// 全セッションを学校年度（4月始まり）ごとにグルーピングし、
/// 測定項目の平均値の年度推移を比較するタブ。
class YearComparisonTab extends StatelessWidget {
  const YearComparisonTab({super.key, required this.data, required this.item});

  final TeamAnalysisData data;
  final MeasurementItem item;

  @override
  Widget build(BuildContext context) {
    final itemRecords = data.datedRecords.where((d) => d.record.itemId == item.id).toList();

    if (itemRecords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: Text('この項目の記録がありません')),
      );
    }

    final valuesByYear = <int, List<double>>{};
    for (final d in itemRecords) {
      final year = TeamAnalysisCalculator.academicYear(d.measurementDate);
      valuesByYear.putIfAbsent(year, () => []).add(d.record.value);
    }

    final years = valuesByYear.keys.toList()..sort();
    final yearAverages = [
      for (final year in years)
        YearAverage(
          year: year,
          average: valuesByYear[year]!.reduce((a, b) => a + b) / valuesByYear[year]!.length,
          count: valuesByYear[year]!.length,
        ),
    ];

    final groups = [
      for (final y in yearAverages) GroupAverage(label: y.label, average: y.average, count: y.count),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (years.length < 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '年度をまたぐ測定データが揃うと推移が比較できます（現在${years.length}年度分）',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Text('年度別平均', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GroupBarChart(groups: groups, unit: item.unit),
            ),
          ),
        ],
      ),
    );
  }
}
