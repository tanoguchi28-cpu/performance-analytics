import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/local_database.dart';
import '../../team_session/data/team_session_provider.dart';
import '../data/local_measurement_repository.dart';

class MeasurementSessionListScreen extends ConsumerStatefulWidget {
  const MeasurementSessionListScreen({super.key});

  @override
  ConsumerState<MeasurementSessionListScreen> createState() =>
      _MeasurementSessionListScreenState();
}

class _MeasurementSessionListScreenState
    extends ConsumerState<MeasurementSessionListScreen> {
  late Future<List<MeasurementSession>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ref.read(measurementRepositoryProvider).getSessions();
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
        title: const Text('測定データ'),
        actions: [
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.upload_file_outlined),
              tooltip: 'Excelから取り込み',
              onPressed: () async {
                await context.push('/measurements/import');
                _refresh();
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: '測定セッションを作成',
              onPressed: () async {
                await context.push('/measurements/new');
                _refresh();
              },
            ),
          ],
        ],
      ),
      body: FutureBuilder<List<MeasurementSession>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('読み込みエラー: ${snapshot.error}'));
          }

          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_note_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('測定セッションがありません'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final s = sessions[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.event_note_outlined),
                    title: Text(
                      s.label ?? DateFormat('yyyy/MM/dd').format(s.measurementDate),
                    ),
                    subtitle: s.label != null
                        ? Text(DateFormat('yyyy/MM/dd').format(s.measurementDate))
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await context.push('/measurements/${s.id}');
                      _refresh();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
