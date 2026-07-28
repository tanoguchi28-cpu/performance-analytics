import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../team_session/data/team_session_provider.dart';
import '../data/local_measurement_repository.dart';

/// 測定セッション（測定実施日）の新規作成・編集フォーム。
/// [sessionId]を渡すと編集モードになる。
class MeasurementSessionFormScreen extends ConsumerStatefulWidget {
  const MeasurementSessionFormScreen({super.key, this.sessionId});

  final String? sessionId;

  @override
  ConsumerState<MeasurementSessionFormScreen> createState() =>
      _MeasurementSessionFormScreenState();
}

class _MeasurementSessionFormScreenState
    extends ConsumerState<MeasurementSessionFormScreen> {
  final _labelController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _measurementDate = DateTime.now();
  bool _loading = true;
  bool _saving = false;

  bool get _isEditing => widget.sessionId != null;

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
    final session =
        await ref.read(measurementRepositoryProvider).getSession(widget.sessionId!);
    if (session != null && mounted) {
      _labelController.text = session.label ?? '';
      _noteController.text = session.note ?? '';
      setState(() {
        _measurementDate = session.measurementDate;
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _measurementDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) setState(() => _measurementDate = picked);
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final repo = ref.read(measurementRepositoryProvider);
    final label =
        _labelController.text.trim().isEmpty ? null : _labelController.text.trim();
    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    try {
      if (_isEditing) {
        await repo.updateSession(
          id: widget.sessionId!,
          measurementDate: _measurementDate,
          label: label,
          note: note,
        );
      } else {
        await repo.createSession(
          measurementDate: _measurementDate,
          label: label,
          note: note,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存に失敗しました。通信環境を確認してもう一度お試しください')),
      );
      return;
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
      appBar: AppBar(title: Text(_isEditing ? '測定セッションを編集' : '測定セッションを作成')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: '測定日 *'),
                    child: Text(DateFormat('yyyy/MM/dd').format(_measurementDate)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _labelController,
                  decoration: const InputDecoration(
                    labelText: 'ラベル',
                    hintText: '例: 2026年度 春季測定',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'メモ'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: (_saving || !canEdit) ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? '更新する' : '作成する'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
