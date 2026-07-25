import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/positions.dart';
import '../../../core/database/local_database.dart';
import '../../../shared/widgets/confirm_delete_dialog.dart';
import '../../evaluation/data/local_evaluation_criteria_repository.dart';
import '../../measurements/data/local_measurement_item_repository.dart';
import '../../team_session/data/team_session_provider.dart';

/// 評価基準（5段階の得点帯）の閲覧・編集画面。項目を選び、ポジション別/共通の
/// 基準セットごとに得点帯の下限・上限を編集する。基準セットは常に得点5〜1の
/// 5段階で構成する（既存の評価エンジン・レーダーチャートの前提と揃える）。
class EvaluationCriteriaManagementScreen extends ConsumerStatefulWidget {
  const EvaluationCriteriaManagementScreen({super.key});

  @override
  ConsumerState<EvaluationCriteriaManagementScreen> createState() =>
      _EvaluationCriteriaManagementScreenState();
}

class _EvaluationCriteriaManagementScreenState
    extends ConsumerState<EvaluationCriteriaManagementScreen> {
  List<MeasurementItem> _items = [];
  String? _selectedItemId;
  List<EvaluationCriterion> _criteria = [];
  Map<String, List<ScoreBand>> _bandsByCriteriaId = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await ref.read(measurementItemRepositoryProvider).getAll(activeOnly: false);
    if (!mounted) return;
    setState(() {
      _items = items;
      _selectedItemId ??= items.isEmpty ? null : items.first.id;
    });
    await _loadCriteria();
  }

  Future<void> _loadCriteria() async {
    final item = _items.where((i) => i.id == _selectedItemId).firstOrNull;
    if (item == null) {
      setState(() {
        _criteria = [];
        _bandsByCriteriaId = {};
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    final repo = ref.read(evaluationCriteriaRepositoryProvider);
    final criteria = await repo.getCriteriaForItem(item.key);
    final bandsByCriteriaId = <String, List<ScoreBand>>{};
    for (final c in criteria) {
      final bands = await repo.getBands(c.id);
      bands.sort((a, b) => b.score.compareTo(a.score));
      bandsByCriteriaId[c.id] = bands;
    }

    if (!mounted) return;
    setState(() {
      _criteria = criteria;
      _bandsByCriteriaId = bandsByCriteriaId;
      _loading = false;
    });
  }

  Future<void> _addCriterion() async {
    final item = _items.where((i) => i.id == _selectedItemId).firstOrNull;
    if (item == null) return;

    final position = await showDialog<String?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('基準を追加'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('ポジション共通'),
          ),
          for (final p in basketballPositions)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, p),
              child: Text(p),
            ),
        ],
      ),
    );
    if (!mounted) return;

    final repo = ref.read(evaluationCriteriaRepositoryProvider);
    final name = '${item.name}${position == null ? ' 共通' : ' $position'} 基準';
    final criteriaId = await repo.createCriterion(
      itemKey: item.key,
      name: name,
      position: position,
    );
    for (var score = 5; score >= 1; score--) {
      await repo.upsertBand(criteriaId: criteriaId, score: score);
    }
    await _loadCriteria();
  }

  Future<void> _deleteCriterion(String criteriaId) async {
    final confirmed = await confirmDelete(
      context,
      title: '基準を削除しますか？',
      message: 'この基準セットと得点帯を削除します。この操作は取り消せません。',
    );
    if (!confirmed) return;

    await ref.read(evaluationCriteriaRepositoryProvider).deleteCriterion(criteriaId);
    await _loadCriteria();
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(canEditProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('評価基準設定'),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: '基準を追加',
              onPressed: _items.isEmpty ? null : _addCriterion,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedItemId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: '測定項目'),
              items: [
                for (final i in _items) DropdownMenuItem(value: i.id, child: Text(i.name)),
              ],
              onChanged: (v) {
                setState(() => _selectedItemId = v);
                _loadCriteria();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _criteria.isEmpty
                    ? const Center(child: Text('この項目にはまだ評価基準がありません'))
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          for (final c in _criteria)
                            _CriterionCard(
                              key: ValueKey(c.id),
                              criterion: c,
                              bands: _bandsByCriteriaId[c.id] ?? [],
                              canEdit: canEdit,
                              onDelete: () => _deleteCriterion(c.id),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _CriterionCard extends ConsumerStatefulWidget {
  const _CriterionCard({
    required super.key,
    required this.criterion,
    required this.bands,
    required this.canEdit,
    required this.onDelete,
  });

  final EvaluationCriterion criterion;
  final List<ScoreBand> bands;
  final bool canEdit;
  final VoidCallback onDelete;

  @override
  ConsumerState<_CriterionCard> createState() => _CriterionCardState();
}

class _CriterionCardState extends ConsumerState<_CriterionCard> {
  late final Map<int, TextEditingController> _minControllers;
  late final Map<int, TextEditingController> _maxControllers;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _minControllers = {
      for (final b in widget.bands) b.score: TextEditingController(text: b.minValue?.toString() ?? ''),
    };
    _maxControllers = {
      for (final b in widget.bands) b.score: TextEditingController(text: b.maxValue?.toString() ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _minControllers.values) {
      c.dispose();
    }
    for (final c in _maxControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(evaluationCriteriaRepositoryProvider);
    for (final b in widget.bands) {
      final minText = _minControllers[b.score]!.text.trim();
      final maxText = _maxControllers[b.score]!.text.trim();
      await repo.upsertBand(
        id: b.id,
        criteriaId: widget.criterion.id,
        score: b.score,
        minValue: minText.isEmpty ? null : double.tryParse(minText),
        maxValue: maxText.isEmpty ? null : double.tryParse(maxText),
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存しました')));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.criterion.position == null ? 'ポジション共通' : widget.criterion.position!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (widget.canEdit)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: '削除',
                    onPressed: widget.onDelete,
                  ),
              ],
            ),
            Text(widget.criterion.name, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            for (final b in widget.bands)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 48, child: Text('評価${b.score}')),
                    Expanded(
                      child: TextField(
                        controller: _minControllers[b.score],
                        readOnly: !widget.canEdit,
                        decoration: const InputDecoration(labelText: '下限（空欄=制限なし）'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('〜'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _maxControllers[b.score],
                        readOnly: !widget.canEdit,
                        decoration: const InputDecoration(labelText: '上限（空欄=制限なし）'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.canEdit) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('保存する'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
