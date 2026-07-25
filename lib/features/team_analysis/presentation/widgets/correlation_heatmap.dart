import 'package:flutter/material.dart';

import '../../domain/team_analysis_models.dart';

/// 全測定項目間のピアソン相関係数をヒートマップ表示する。
/// 項目数が多くても崩れないよう横スクロール可能にしている。
class CorrelationHeatmap extends StatelessWidget {
  const CorrelationHeatmap({super.key, required this.matrix});

  final CorrelationMatrix matrix;

  static const _cellSize = 56.0;
  static const _rowLabelWidth = 120.0;
  static const _headerHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    if (matrix.items.length < 2) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('相関を算出するには測定項目が2つ以上必要です')),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: _rowLabelWidth),
              for (final item in matrix.items)
                SizedBox(
                  width: _cellSize,
                  height: _headerHeight,
                  child: Transform.rotate(
                    angle: -0.6,
                    alignment: Alignment.bottomLeft,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          for (var row = 0; row < matrix.items.length; row++)
            Row(
              children: [
                SizedBox(
                  width: _rowLabelWidth,
                  height: _cellSize,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      matrix.items[row].name,
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                for (var col = 0; col < matrix.items.length; col++)
                  _HeatmapCell(value: matrix.values[row][col]),
              ],
            ),
        ],
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({required this.value});

  final double? value;

  @override
  Widget build(BuildContext context) {
    final v = value;
    final color = v == null
        ? Colors.grey.withValues(alpha: 0.15)
        : (v >= 0 ? const Color(0xFF2E7D32) : const Color(0xFFE53935))
            .withValues(alpha: v.abs().clamp(0.08, 1.0));

    return Container(
      width: CorrelationHeatmap._cellSize,
      height: CorrelationHeatmap._cellSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5),
      ),
      child: Text(
        v == null ? '-' : v.toStringAsFixed(2),
        style: TextStyle(
          fontSize: 10,
          fontWeight: v != null && v.abs() >= 0.7 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
