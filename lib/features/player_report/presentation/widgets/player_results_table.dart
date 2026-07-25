import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/player_report_models.dart';

class PlayerResultsTable extends StatelessWidget {
  const PlayerResultsTable({super.key, required this.results});

  final List<PlayerResultRow> results;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('測定結果一覧', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2),
              },
              children: [
                _headerRow(context),
                for (final r in results) _dataRow(context, r),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _headerRow(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium;
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('項目', style: style)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('記録', style: style)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('前回比', style: style)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('評価', style: style)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('順位', style: style)),
      ],
    );
  }

  TableRow _dataRow(BuildContext context, PlayerResultRow r) {
    final value = r.latestValue;
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(r.item.name),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(value == null ? '未測定' : '$value ${r.item.unit}'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _PercentChangeLabel(percentChange: r.percentChange),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: r.evaluationScore == null
              ? Text('評価なし', style: Theme.of(context).textTheme.bodySmall)
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: evaluationScoreColor(r.evaluationScore!).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${r.evaluationScore}',
                    style: TextStyle(
                      color: evaluationScoreColor(r.evaluationScore!),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(r.rank == null ? '-' : '${r.rank}位 / ${r.teamSize}人'),
        ),
      ],
    );
  }
}

/// 前回（1つ前の測定日）からの変化率。プラスは常に「改善」を意味する
/// （higherIsBetter=falseの項目は[StatisticsCalculator.percentChange]側で符号調整済み）。
class _PercentChangeLabel extends StatelessWidget {
  const _PercentChangeLabel({required this.percentChange});

  final double? percentChange;

  @override
  Widget build(BuildContext context) {
    final value = percentChange;
    if (value == null) {
      return Text('-', style: Theme.of(context).textTheme.bodySmall);
    }

    final improved = value > 0;
    final flat = value == 0;
    final color = flat
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : (improved ? const Color(0xFF2E7D32) : const Color(0xFFE53935));
    final icon = flat
        ? Icons.remove
        : (improved ? Icons.arrow_upward : Icons.arrow_downward);

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            '${value.abs().toStringAsFixed(1)}%',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
