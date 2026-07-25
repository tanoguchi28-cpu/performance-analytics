import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/ability_category.dart';
import '../../../core/database/local_database.dart';
import '../../measurements/data/local_measurement_item_repository.dart';
import '../../team_session/data/team_session_provider.dart';

/// 測定項目の新規登録・編集フォーム。[itemId]を渡すと編集モードになる。
/// [key]は測定データ・評価基準から参照されるため編集時は変更不可にする。
class MeasurementItemFormScreen extends ConsumerStatefulWidget {
  const MeasurementItemFormScreen({super.key, this.itemId});

  final String? itemId;

  @override
  ConsumerState<MeasurementItemFormScreen> createState() => _MeasurementItemFormScreenState();
}

class _MeasurementItemFormScreenState extends ConsumerState<MeasurementItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _sortOrderController = TextEditingController(text: '0');

  bool _higherIsBetter = true;
  AbilityCategory _abilityCategory = AbilityCategory.none;
  bool _loading = true;
  bool _saving = false;

  bool get _isEditing => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!_isEditing) {
      setState(() => _loading = false);
      return;
    }
    final items = await ref.read(measurementItemRepositoryProvider).getAll(activeOnly: false);
    final item = items.where((i) => i.id == widget.itemId).firstOrNull;
    if (item != null && mounted) {
      _keyController.text = item.key;
      _nameController.text = item.name;
      _unitController.text = item.unit;
      _sortOrderController.text = item.sortOrder.toString();
      setState(() {
        _higherIsBetter = item.higherIsBetter;
        _abilityCategory = item.abilityCategory;
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _nameController.dispose();
    _unitController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final repo = ref.read(measurementItemRepositoryProvider);
    final sortOrder = int.tryParse(_sortOrderController.text.trim()) ?? 0;

    if (_isEditing) {
      await repo.update(
        widget.itemId!,
        MeasurementItemsCompanion(
          name: Value(_nameController.text.trim()),
          unit: Value(_unitController.text.trim()),
          higherIsBetter: Value(_higherIsBetter),
          abilityCategory: Value(_abilityCategory),
          sortOrder: Value(sortOrder),
        ),
      );
    } else {
      await repo.create(
        MeasurementItemsCompanion(
          key: Value(_keyController.text.trim()),
          name: Value(_nameController.text.trim()),
          unit: Value(_unitController.text.trim()),
          higherIsBetter: Value(_higherIsBetter),
          abilityCategory: Value(_abilityCategory),
          sortOrder: Value(sortOrder),
        ),
      );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final canEdit = ref.watch(canEditProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '測定項目を編集' : '測定項目を追加')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _keyController,
                    enabled: !_isEditing,
                    decoration: InputDecoration(
                      labelText: '項目キー *',
                      helperText: _isEditing ? '登録済みデータとの紐付けのため変更できません' : '英数字・アンダースコア推奨（例: vertical_jump）',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? '項目キーを入力してください' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '項目名 *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? '項目名を入力してください' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _unitController,
                          decoration: const InputDecoration(labelText: '単位 *'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? '単位を入力してください' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _sortOrderController,
                          decoration: const InputDecoration(labelText: '表示順'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AbilityCategory>(
                    initialValue: _abilityCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: '能力カテゴリ（レーダーチャート）'),
                    items: [
                      for (final c in AbilityCategory.values)
                        DropdownMenuItem(value: c, child: Text(c.label)),
                    ],
                    onChanged: (v) => setState(() => _abilityCategory = v ?? _abilityCategory),
                  ),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('値が大きいほど良い記録'),
                    subtitle: const Text('タイム系（低いほど良い）はオフにする'),
                    value: _higherIsBetter,
                    onChanged: (v) => setState(() => _higherIsBetter = v),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: (_saving || !canEdit) ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? '更新する' : '追加する'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
