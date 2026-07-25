import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/local_database.dart';
import '../../../shared/widgets/filter_chip_group.dart';
import '../../../shared/widgets/player_avatar.dart';
import '../../athletes/data/local_athlete_repository.dart';
import '../../measurements/data/local_measurement_item_repository.dart';
import '../../measurements/data/local_measurement_repository.dart';
import '../domain/ranking_calculator.dart';

enum _RankingMode { overall, byItem }

enum _DisplayCount {
  top3(3, 'TOP3'),
  top10(10, 'TOP10'),
  all(null, '全順位');

  const _DisplayCount(this.limit, this.label);
  final int? limit;
  final String label;
}

class _RankingData {
  const _RankingData({
    required this.athletes,
    required this.items,
    required this.records,
    required this.measurementDate,
  });

  final List<Athlete> athletes;
  final List<MeasurementItem> items;
  final List<MeasurementRecord> records;

  /// ランキング算出に使ったセッション（最新）の測定日。セッションが無ければnull。
  final DateTime? measurementDate;
}

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  late Future<_RankingData> _future;

  _RankingMode _mode = _RankingMode.overall;
  String? _selectedItemId;
  String? _positionFilter;
  _DisplayCount _displayCount = _DisplayCount.top10;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_RankingData> _load() async {
    final athleteRepo = ref.read(athleteRepositoryProvider);
    final itemRepo = ref.read(measurementItemRepositoryProvider);
    final measurementRepo = ref.read(measurementRepositoryProvider);

    final results = await Future.wait([
      athleteRepo.getAll(),
      itemRepo.getAll(),
      measurementRepo.getSessions(),
    ]);
    final athletes = results[0] as List<Athlete>;
    final items = results[1] as List<MeasurementItem>;
    final sessions = results[2] as List<MeasurementSession>;

    final records = sessions.isEmpty
        ? <MeasurementRecord>[]
        : await measurementRepo.getRecordsForSession(sessions.first.id);

    return _RankingData(
      athletes: athletes,
      items: items,
      records: records,
      measurementDate: sessions.isEmpty ? null : sessions.first.measurementDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ランキング')),
      body: FutureBuilder<_RankingData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('読み込みエラー: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          _selectedItemId ??= data.items.isEmpty ? null : data.items.first.id;

          final filteredAthletes = data.athletes.where((a) {
            if (_positionFilter != null && a.position != _positionFilter) return false;
            return true;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SegmentedButton<_RankingMode>(
                  segments: const [
                    ButtonSegment(value: _RankingMode.overall, label: Text('総合順位')),
                    ButtonSegment(value: _RankingMode.byItem, label: Text('項目別順位')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
              ),
              if (_mode == _RankingMode.byItem && data.items.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedItemId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: '測定項目'),
                    items: data.items
                        .map((i) => DropdownMenuItem(value: i.id, child: Text(i.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedItemId = v),
                  ),
                ),
                if (data.measurementDate != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '測定日: ${DateFormat('yyyy/MM/dd').format(data.measurementDate!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    FilterChipGroup<String?>(
                      value: _positionFilter,
                      options: const [null, 'G', 'F', 'C'],
                      labelBuilder: (v) => v ?? '全ポジション',
                      onChanged: (v) => setState(() => _positionFilter = v),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SegmentedButton<_DisplayCount>(
                  segments: [
                    for (final d in _DisplayCount.values)
                      ButtonSegment(value: d, label: Text(d.label)),
                  ],
                  selected: {_displayCount},
                  onSelectionChanged: (s) => setState(() => _displayCount = s.first),
                ),
              ),
              Expanded(
                child: _buildList(context, data, filteredAthletes),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, _RankingData data, List<Athlete> filteredAthletes) {
    if (_mode == _RankingMode.overall) {
      final entries = RankingCalculator.computeOverallRanking(
        athletes: filteredAthletes,
        items: data.items,
        records: data.records,
      );
      final limited = _applyLimit(entries);
      if (limited.isEmpty) return const _EmptyState();

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: limited.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final e = limited[i];
          return _RankingTile(
            rank: e.rank,
            athlete: e.athlete,
            valueLabel: '偏差値相当 ${e.averageDeviationScore.toStringAsFixed(1)}',
            subLabel: '${e.itemCount}項目の平均',
          );
        },
      );
    }

    final item = data.items.where((i) => i.id == _selectedItemId).firstOrNull;
    if (item == null) return const _EmptyState();

    final entries = RankingCalculator.computeItemRanking(
      athletes: filteredAthletes,
      item: item,
      records: data.records,
    );
    final limited = _applyLimit(entries);
    if (limited.isEmpty) return const _EmptyState();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: limited.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final e = limited[i];
        return _RankingTile(
          rank: e.rank,
          athlete: e.athlete,
          valueLabel: '${e.value} ${item.unit}',
        );
      },
    );
  }

  List<T> _applyLimit<T>(List<T> entries) {
    final limit = _displayCount.limit;
    if (limit == null) return entries;
    return entries.take(limit).toList();
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile({
    required this.rank,
    required this.athlete,
    required this.valueLabel,
    this.subLabel,
  });

  final int rank;
  final Athlete athlete;
  final String valueLabel;
  final String? subLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTop3 = rank <= 3;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isTop3 ? cs.primary : cs.onSurfaceVariant,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            PlayerAvatar(photoPath: athlete.photoPath, radius: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(athlete.name, overflow: TextOverflow.ellipsis),
                  if (athlete.position != null)
                    Text(
                      athlete.position!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(valueLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (subLabel != null)
                  Text(subLabel!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.leaderboard_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('該当するランキングデータがありません'),
        ],
      ),
    );
  }
}
