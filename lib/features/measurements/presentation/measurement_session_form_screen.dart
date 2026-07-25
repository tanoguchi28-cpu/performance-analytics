import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../team_session/data/team_session_provider.dart';
import '../data/local_measurement_repository.dart';

/// 測定セッション（測定実施日）の新規作成フォーム。
class MeasurementSessionFormScreen extends ConsumerStatefulWidget {
  const MeasurementSessionFormScreen({super.key});

  @override
  ConsumerState<MeasurementSessionFormScreen> createState() =>
      _MeasurementSessionFormScreenState();
}

class _MeasurementSessionFormScreenState
    extends ConsumerState<MeasurementSessionFormScreen> {
  final _labelController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _measurementDate = DateTime.now();
  bool _saving = false;

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
    await ref.read(measurementRepositoryProvider).createSession(
          measurementDate: _measurementDate,
          label: _labelController.text.trim().isEmpty
              ? null
              : _labelController.text.trim(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(canEditProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('測定セッションを作成')),
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
                      : const Text('作成する'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
