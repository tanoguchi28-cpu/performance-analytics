import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/local_database.dart';
import '../../measurements/data/local_measurement_item_repository.dart';
import '../../team_session/data/team_session_provider.dart';

/// 測定項目マスタの一覧・有効/無効切替。追加・編集はフォーム画面で行う。
class MeasurementItemManagementScreen extends ConsumerStatefulWidget {
  const MeasurementItemManagementScreen({super.key});

  @override
  ConsumerState<MeasurementItemManagementScreen> createState() =>
      _MeasurementItemManagementScreenState();
}

class _MeasurementItemManagementScreenState extends ConsumerState<MeasurementItemManagementScreen> {
  late Future<List<MeasurementItem>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ref.read(measurementItemRepositoryProvider).getAll(activeOnly: false);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _toggleActive(MeasurementItem item) async {
    final repo = ref.read(measurementItemRepositoryProvider);
    if (item.isActive) {
      await repo.deactivate(item.id);
    } else {
      await repo.update(item.id, const MeasurementItemsCompanion(isActive: Value(true)));
    }
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(canEditProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('測定項目管理'),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: '項目を追加',
              onPressed: () async {
                await context.push('/settings/measurement-items/new');
                _refresh();
              },
            ),
        ],
      ),
      body: FutureBuilder<List<MeasurementItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('読み込みエラー: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('測定項目がありません'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final item = items[i];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.unit} / ${item.higherIsBetter ? "高いほど良い" : "低いほど良い"} '
                    '/ ${item.abilityCategory.label}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: item.isActive,
                        onChanged: canEdit ? (_) => _toggleActive(item) : null,
                      ),
                      if (canEdit)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: '編集',
                          onPressed: () async {
                            await context.push('/settings/measurement-items/${item.id}/edit');
                            _refresh();
                          },
                        ),
                    ],
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
