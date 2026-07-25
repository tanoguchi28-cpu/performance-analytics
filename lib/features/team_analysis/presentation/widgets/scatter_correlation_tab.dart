import 'package:flutter/material.dart';

import '../../../../core/database/local_database.dart';
import '../../domain/team_analysis_calculator.dart';
import '../../domain/team_analysis_models.dart';
import 'correlation_heatmap.dart';
import 'scatter_correlation_chart.dart';

/// 2項目間の散布図・相関係数と、全項目の相関ヒートマップを表示するタブ。
class ScatterCorrelationTab extends StatefulWidget {
  const ScatterCorrelationTab({super.key, required this.data});

  final TeamAnalysisData data;

  @override
  State<ScatterCorrelationTab> createState() => _ScatterCorrelationTabState();
}

class _ScatterCorrelationTabState extends State<ScatterCorrelationTab> {
  String? _xItemId;
  String? _yItemId;

  @override
  Widget build(BuildContext context) {
    final items = widget.data.items;
    if (items.length < 2) {
      return const Center(child: Text('相関を見るには測定項目が2つ以上必要です'));
    }

    _xItemId ??= items[0].id;
    _yItemId ??= items.length > 1 ? items[1].id : items[0].id;

    final xItem = items.firstWhere((i) => i.id == _xItemId);
    final yItem = items.firstWhere((i) => i.id == _yItemId);

    final valuesByAthleteAndItem = <(String, String), double>{
      for (final r in widget.data.selectedSessionRecords) (r.athleteId, r.itemId): r.value,
    };
    final athleteById = {for (final a in widget.data.athletes) a.id: a};

    final points = <AthletePoint>[];
    for (final athlete in widget.data.athletes) {
      final x = valuesByAthleteAndItem[(athlete.id, xItem.id)];
      final y = valuesByAthleteAndItem[(athlete.id, yItem.id)];
      if (x == null || y == null) continue;
      points.add(AthletePoint(athlete: athlete, x: x, y: y));
    }

    final r = TeamAnalysisCalculator.pearsonCorrelation(
      points.map((p) => p.x).toList(),
      points.map((p) => p.y).toList(),
    );

    final matrix = _buildCorrelationMatrix(
      items: items,
      records: widget.data.selectedSessionRecords,
      athleteIds: athleteById.keys.toList(),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _xItemId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'X軸の項目'),
                  items: [
                    for (final i in items) DropdownMenuItem(value: i.id, child: Text(i.name)),
                  ],
                  onChanged: (v) => setState(() => _xItemId = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _yItemId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Y軸の項目'),
                  items: [
                    for (final i in items) DropdownMenuItem(value: i.id, child: Text(i.name)),
                  ],
                  onChanged: (v) => setState(() => _yItemId = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r == null ? '相関係数: 算出不可' : '相関係数: ${r.toStringAsFixed(2)}（${_interpret(r)}）',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ScatterCorrelationChart(
                    points: points,
                    xLabel: '${xItem.name}（${xItem.unit}）',
                    yLabel: '${yItem.name}（${yItem.unit}）',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('全項目の相関ヒートマップ', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CorrelationHeatmap(matrix: matrix),
            ),
          ),
        ],
      ),
    );
  }

  String _interpret(double r) {
    final abs = r.abs();
    if (abs >= 0.7) return '強い相関';
    if (abs >= 0.4) return 'やや相関あり';
    if (abs >= 0.2) return '弱い相関';
    return 'ほぼ無相関';
  }

  CorrelationMatrix _buildCorrelationMatrix({
    required List<MeasurementItem> items,
    required List<MeasurementRecord> records,
    required List<String> athleteIds,
  }) {
    final valuesByAthleteAndItem = <(String, String), double>{
      for (final r in records) (r.athleteId, r.itemId): r.value,
    };

    final values = List.generate(
      items.length,
      (_) => List<double?>.filled(items.length, null),
    );

    for (var i = 0; i < items.length; i++) {
      for (var j = 0; j < items.length; j++) {
        if (i == j) {
          values[i][j] = 1.0;
          continue;
        }
        final xs = <double>[];
        final ys = <double>[];
        for (final athleteId in athleteIds) {
          final x = valuesByAthleteAndItem[(athleteId, items[i].id)];
          final y = valuesByAthleteAndItem[(athleteId, items[j].id)];
          if (x == null || y == null) continue;
          xs.add(x);
          ys.add(y);
        }
        values[i][j] = TeamAnalysisCalculator.pearsonCorrelation(xs, ys);
      }
    }

    return CorrelationMatrix(items: items, values: values);
  }
}
