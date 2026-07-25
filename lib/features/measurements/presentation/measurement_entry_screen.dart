import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/local_database.dart';
import '../../athletes/data/local_athlete_repository.dart';
import '../../team_session/data/team_session_provider.dart';
import '../data/local_measurement_item_repository.dart';
import '../data/local_measurement_repository.dart';

class _EntryData {
  const _EntryData({
    required this.athlete,
    required this.items,
    required this.existingValues,
  });

  final Athlete athlete;
  final List<MeasurementItem> items;
  final Map<String, double> existingValues; // itemId -> value
}

/// 1選手 × 1測定セッション の測定値をまとめて入力・編集する画面。
class MeasurementEntryScreen extends ConsumerStatefulWidget {
  const MeasurementEntryScreen({
    super.key,
    required this.sessionId,
    required this.athleteId,
  });

  final String sessionId;
  final String athleteId;

  @override
  ConsumerState<MeasurementEntryScreen> createState() => _MeasurementEntryScreenState();
}

class _MeasurementEntryScreenState extends ConsumerState<MeasurementEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  late Future<_EntryData> _future;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<_EntryData> _fetch() async {
    final athleteRepo = ref.read(athleteRepositoryProvider);
    final itemRepo = ref.read(measurementItemRepositoryProvider);
    final measurementRepo = ref.read(measurementRepositoryProvider);

    final results = await Future.wait([
      athleteRepo.getById(widget.athleteId),
      itemRepo.getAll(),
      measurementRepo.getRecordsForSession(widget.sessionId),
    ]);

    final athlete = results[0] as Athlete?;
    if (athlete == null) {
      throw StateError('選手が見つかりません');
    }
    final items = results[1] as List<MeasurementItem>;
    final records = results[2] as List<MeasurementRecord>;

    final existingValues = <String, double>{
      for (final r in records)
        if (r.athleteId == widget.athleteId) r.itemId: r.value,
    };

    for (final item in items) {
      final value = existingValues[item.id];
      _controllers[item.id] = TextEditingController(
        text: value == null ? '' : _formatValue(value),
      );
    }

    return _EntryData(athlete: athlete, items: items, existingValues: existingValues);
  }

  String _formatValue(double value) {
    return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
  }

  Future<void> _submit(_EntryData data) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final repo = ref.read(measurementRepositoryProvider);
    for (final item in data.items) {
      final text = _controllers[item.id]!.text.trim();
      if (text.isEmpty) {
        // 既存の記録があった項目を空にして保存した場合は、誤入力の取り消しとして
        // 記録そのものを削除する（何もしないと古い値が残り続けてしまう）。
        if (data.existingValues.containsKey(item.id)) {
          await repo.deleteRecord(
            athleteId: widget.athleteId,
            sessionId: widget.sessionId,
            itemId: item.id,
          );
        }
        continue;
      }
      final value = double.tryParse(text);
      if (value == null) continue;
      await repo.upsertRecord(
        athleteId: widget.athleteId,
        sessionId: widget.sessionId,
        itemId: item.id,
        value: value,
      );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('測定値入力')),
      body: FutureBuilder<_EntryData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('読み込みエラー: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final canEdit = ref.watch(canEditProvider);
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        data.athlete.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      if (data.athlete.position != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          data.athlete.position!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (canEdit) ...[
                        const SizedBox(height: 8),
                        Text(
                          '項目を空にして保存すると、その記録は削除されます。',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                      const SizedBox(height: 24),
                      for (final item in data.items) ...[
                        TextFormField(
                          controller: _controllers[item.id],
                          readOnly: !canEdit,
                          decoration: InputDecoration(
                            labelText: item.name,
                            suffixText: item.unit,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            return double.tryParse(v.trim()) == null ? '数値を入力してください' : null;
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (canEdit) ...[
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _saving ? null : () => _submit(data),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('保存する'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
