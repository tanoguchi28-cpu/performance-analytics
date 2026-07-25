import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/local_database.dart';
import '../../../athletes/data/local_athlete_repository.dart';
import '../../../team_session/data/team_session_provider.dart';

class CoachCommentCard extends ConsumerStatefulWidget {
  const CoachCommentCard({super.key, required this.athlete});

  final Athlete athlete;

  @override
  ConsumerState<CoachCommentCard> createState() => _CoachCommentCardState();
}

class _CoachCommentCardState extends ConsumerState<CoachCommentCard> {
  late final TextEditingController _controller;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.athlete.coachComment ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(athleteRepositoryProvider).update(
          widget.athlete.id,
          AthletesCompanion(
            coachComment: Value(_controller.text.trim().isEmpty ? null : _controller.text.trim()),
          ),
        );
    if (mounted) setState(() { _saving = false; _dirty = false; });
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(canEditProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('コーチコメント', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 4,
              readOnly: !canEdit,
              decoration: const InputDecoration(
                hintText: '選手へのコメントを記入してください',
                border: OutlineInputBorder(),
              ),
              onChanged: canEdit ? (_) => setState(() => _dirty = true) : null,
            ),
            if (canEdit) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: (_dirty && !_saving) ? _save : null,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
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
