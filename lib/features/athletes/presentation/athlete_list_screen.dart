import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/local_database.dart';
import '../../../shared/widgets/filter_chip_group.dart';
import '../../team_session/data/team_session_provider.dart';
import '../data/local_athlete_repository.dart';
import 'widgets/athlete_card.dart';

class AthleteListScreen extends ConsumerStatefulWidget {
  const AthleteListScreen({super.key});

  @override
  ConsumerState<AthleteListScreen> createState() => _AthleteListScreenState();
}

class _AthleteListScreenState extends ConsumerState<AthleteListScreen> {
  String _search = '';
  String? _positionFilter;
  late Future<List<Athlete>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ref.read(athleteRepositoryProvider).getAll();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(canEditProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('選手一覧'),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: '選手を登録',
              onPressed: () async {
                await context.push('/athletes/new');
                _refresh();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              hintText: '氏名で検索',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChipGroup<String?>(
                  value: _positionFilter,
                  options: const [null, 'G', 'F', 'C'],
                  labelBuilder: (v) => v ?? '全て',
                  onChanged: (v) => setState(() => _positionFilter = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Athlete>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('読み込みエラー: ${snapshot.error}'));
                }

                var athletes = snapshot.data ?? [];
                if (_search.isNotEmpty) {
                  athletes = athletes
                      .where((a) => a.name.contains(_search))
                      .toList();
                }
                if (_positionFilter != null) {
                  athletes = athletes
                      .where((a) => a.position == _positionFilter)
                      .toList();
                }

                if (athletes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group_off, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('該当する選手がいません'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: athletes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => AthleteCard(
                      athlete: athletes[i],
                      onTap: () async {
                        await context.push('/athletes/${athletes[i].id}');
                        _refresh();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
