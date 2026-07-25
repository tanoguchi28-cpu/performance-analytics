import 'package:flutter/material.dart';

import '../../../../core/database/local_database.dart';
import '../../domain/team_analysis_models.dart';
import 'group_ability_radar_chart.dart';
import 'group_bar_chart.dart';

/// ポジション別に測定項目の平均値と能力レーダーを比較するタブ。
class GroupComparisonTab extends StatelessWidget {
  const GroupComparisonTab({super.key, required this.data, required this.item});

  final TeamAnalysisData data;
  final MeasurementItem item;

  static const _positionOrder = ['G', 'F', 'C'];

  @override
  Widget build(BuildContext context) {
    final athleteById = {for (final a in data.athletes) a.id: a};
    final records = data.selectedSessionRecords.where((r) => r.itemId == item.id).toList();

    final positionAverages = _averagesByGroup(
      records: records,
      athleteById: athleteById,
      groupKey: (a) => a.position,
      sortOrder: _positionOrder,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ポジション別平均', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GroupBarChart(groups: positionAverages, unit: item.unit),
            ),
          ),
          const SizedBox(height: 20),
          Text('ポジション別 能力レーダー比較', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: GroupAbilityRadarChart(
                  profilesByLabel: _sorted(data.abilityByPosition, _positionOrder),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, T> _sorted<T>(Map<String, T> map, List<String> order) {
    final keys = map.keys.toList()
      ..sort((a, b) {
        final ia = order.indexOf(a);
        final ib = order.indexOf(b);
        if (ia == -1 && ib == -1) return a.compareTo(b);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia.compareTo(ib);
      });
    return {for (final k in keys) k: map[k] as T};
  }

  List<GroupAverage> _averagesByGroup({
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

    final sortedMap = _sorted(valuesByGroup, sortOrder);
    return [
      for (final entry in sortedMap.entries)
        GroupAverage(
          label: entry.key,
          average: entry.value.reduce((a, b) => a + b) / entry.value.length,
          count: entry.value.length,
        ),
    ];
  }
}
