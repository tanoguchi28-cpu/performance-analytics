import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/local_database.dart';
import '../../../shared/widgets/confirm_delete_dialog.dart';
import '../../../shared/widgets/player_avatar.dart';
import '../../athletes/data/local_athlete_repository.dart';
import '../../team_session/data/team_session_provider.dart';
import '../data/local_measurement_item_repository.dart';
import '../data/local_measurement_repository.dart';

class _SessionData {
  const _SessionData({
    required this.session,
    required this.athletes,
    required this.itemCount,
    required this.recordCountByAthlete,
  });

  final MeasurementSession session;
  final List<Athlete> athletes;
  final int itemCount;
  final Map<String, int> recordCountByAthlete;
}

/// セッション内の選手別の入力状況一覧。タップで個人の入力フォームへ遷移する。
class MeasurementSessionDetailScreen extends ConsumerStatefulWidget {
  const MeasurementSessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<MeasurementSessionDetailScreen> createState() =>
      _MeasurementSessionDetailScreenState();
}

class _MeasurementSessionDetailScreenState
    extends ConsumerState<MeasurementSessionDetailScreen> {
  late Future<_SessionData> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _fetch();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _confirmAndDelete() async {
    final repo = ref.read(measurementRepositoryProvider);
    final session = await repo.getSession(widget.sessionId);
    if (!mounted || session == null) return;

    final label = session.label ?? DateFormat('yyyy/MM/dd').format(session.measurementDate);
    final confirmed = await confirmDelete(
      context,
      title: '測定セッションを削除しますか？',
      message: '「$label」を削除します。このセッションに含まれる全選手・全項目の測定記録も'
          'まとめて削除され、この操作は取り消せません。',
    );
    if (!confirmed) return;

    await repo.deleteSession(widget.sessionId);
    if (mounted) context.pop();
  }

  Future<_SessionData> _fetch() async {
    final measurementRepo = ref.read(measurementRepositoryProvider);
    final athleteRepo = ref.read(athleteRepositoryProvider);
    final itemRepo = ref.read(measurementItemRepositoryProvider);

    final results = await Future.wait([
      measurementRepo.getSession(widget.sessionId),
      athleteRepo.getAll(),
      itemRepo.getAll(),
      measurementRepo.getRecordsForSession(widget.sessionId),
    ]);

    final session = results[0] as MeasurementSession?;
    if (session == null) {
      throw StateError('セッションが見つかりません');
    }
    final athletes = results[1] as List<Athlete>;
    final items = results[2] as List<MeasurementItem>;
    final records = results[3] as List<MeasurementRecord>;

    final recordCountByAthlete = <String, int>{};
    for (final r in records) {
      recordCountByAthlete[r.athleteId] = (recordCountByAthlete[r.athleteId] ?? 0) + 1;
    }

    return _SessionData(
      session: session,
      athletes: athletes,
      itemCount: items.length,
      recordCountByAthlete: recordCountByAthlete,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(canEditProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('選手別入力状況'),
        actions: [
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'セッションを編集',
              onPressed: () async {
                await context.push('/measurements/${widget.sessionId}/edit');
                if (mounted) await _refresh();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'セッションを削除',
              onPressed: _confirmAndDelete,
            ),
          ],
        ],
      ),
      body: FutureBuilder<_SessionData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('読み込みエラー: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.session.label ??
                              DateFormat('yyyy/MM/dd').format(data.session.measurementDate),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          DateFormat('yyyy/MM/dd').format(data.session.measurementDate),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (data.session.note != null) ...[
                          const SizedBox(height: 8),
                          Text(data.session.note!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                for (final athlete in data.athletes)
                  Card(
                    child: ListTile(
                      leading: PlayerAvatar(photoPath: athlete.photoPath, radius: 20),
                      title: Text(athlete.name),
                      subtitle: athlete.position == null ? null : Text(athlete.position!),
                      trailing: _CompletionBadge(
                        done: data.recordCountByAthlete[athlete.id] ?? 0,
                        total: data.itemCount,
                      ),
                      onTap: () async {
                        await context.push(
                          '/measurements/${widget.sessionId}/athletes/${athlete.id}',
                        );
                        _refresh();
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  const _CompletionBadge({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final complete = total > 0 && done >= total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: complete ? cs.primaryContainer : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$done/$total',
        style: TextStyle(
          color: complete ? cs.onPrimaryContainer : cs.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
