import 'package:flutter/material.dart';

import '../../../../core/database/local_database.dart';
import '../../../ranking/domain/ranking_models.dart';

const _overallTopN = 10;

/// チームレポート用の総合ランキングTOP10と、項目別ランキングTOP3の一覧。
class RankingSummaryCard extends StatelessWidget {
  const RankingSummaryCard({
    super.key,
    required this.overallRanking,
    required this.items,
    required this.itemRankingsByItemId,
  });

  final List<OverallRankingEntry> overallRanking;
  final List<MeasurementItem> items;
  final Map<String, List<ItemRankingEntry>> itemRankingsByItemId;

  @override
  Widget build(BuildContext context) {
    final topOverall = overallRanking.take(_overallTopN).toList();
    final itemsWithRanking = items.where((i) => (itemRankingsByItemId[i.id]?.isNotEmpty ?? false)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('総合ランキング TOP$_overallTopN', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (topOverall.isEmpty)
              const Text('データがありません')
            else
              for (final e in topOverall)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${e.rank}位　${e.athlete.name}　'
                    '（偏差値相当 ${e.averageDeviationScore.toStringAsFixed(1)}）',
                  ),
                ),
            const SizedBox(height: 20),
            Text('項目別ランキング TOP3', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (itemsWithRanking.isEmpty)
              const Text('データがありません')
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('項目')),
                    DataColumn(label: Text('1位')),
                    DataColumn(label: Text('2位')),
                    DataColumn(label: Text('3位')),
                  ],
                  rows: [
                    for (final item in itemsWithRanking)
                      DataRow(
                        cells: [
                          DataCell(Text(item.name)),
                          for (var i = 0; i < 3; i++)
                            DataCell(Text(_rankLabel(itemRankingsByItemId[item.id]!, i, item.unit))),
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

  String _rankLabel(List<ItemRankingEntry> ranking, int index, String unit) {
    if (index >= ranking.length) return '-';
    final e = ranking[index];
    return '${e.athlete.name}\n(${e.value}$unit)';
  }
}
