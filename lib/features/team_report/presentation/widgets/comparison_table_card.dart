import 'package:flutter/material.dart';

import '../../domain/team_report_models.dart';

/// 項目×グループ（学年別・ポジション別・年度別）の平均値比較テーブルを表示する。
class ComparisonTableCard extends StatelessWidget {
  const ComparisonTableCard({super.key, required this.title, required this.table});

  final String title;
  final ComparisonTable table;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (table.isEmpty)
              const Text('データがありません')
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('項目')),
                    for (final label in table.columnLabels) DataColumn(label: Text(label)),
                  ],
                  rows: [
                    for (final row in table.rows)
                      DataRow(
                        cells: [
                          DataCell(Text(row.item.name)),
                          for (final value in row.values)
                            DataCell(Text(value == null ? '-' : value.toStringAsFixed(1))),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
