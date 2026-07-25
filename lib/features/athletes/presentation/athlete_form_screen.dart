import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/positions.dart';
import '../../../core/database/local_database.dart';
import '../../../shared/widgets/player_avatar.dart';
import '../../team_session/data/team_session_provider.dart';
import '../data/local_athlete_repository.dart';

/// 選手の新規登録・編集フォーム。[athleteId]を渡すと編集モードになる。
class AthleteFormScreen extends ConsumerStatefulWidget {
  const AthleteFormScreen({super.key, this.athleteId});

  final String? athleteId;

  @override
  ConsumerState<AthleteFormScreen> createState() => _AthleteFormScreenState();
}

class _AthleteFormScreenState extends ConsumerState<AthleteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _kanaController = TextEditingController();
  final _jerseyController = TextEditingController();

  String? _position;
  DateTime? _birthDate;
  String? _photoPath;
  bool _loading = true;
  bool _saving = false;

  bool get _isEditing => widget.athleteId != null;

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
    final athlete = await ref
        .read(athleteRepositoryProvider)
        .getById(widget.athleteId!);
    if (athlete != null && mounted) {
      _nameController.text = athlete.name;
      _kanaController.text = athlete.kana ?? '';
      _jerseyController.text = athlete.jerseyNumber?.toString() ?? '';
      setState(() {
        _position = athlete.position;
        _birthDate = athlete.birthDate;
        _photoPath = athlete.photoPath;
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _kanaController.dispose();
    _jerseyController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _photoPath = picked.path);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 16, 4, 1),
      firstDate: DateTime(now.year - 25),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final repo = ref.read(athleteRepositoryProvider);
    final jerseyText = _jerseyController.text.trim();

    final companion = AthletesCompanion(
      name: Value(_nameController.text.trim()),
      kana: Value(
        _kanaController.text.trim().isEmpty ? null : _kanaController.text.trim(),
      ),
      position: Value(_position),
      birthDate: Value(_birthDate),
      photoPath: Value(_photoPath),
      jerseyNumber: Value(jerseyText.isEmpty ? null : int.tryParse(jerseyText)),
    );

    if (_isEditing) {
      await repo.update(widget.athleteId!, companion);
    } else {
      // gradeは学年跨ぎで意味を持たなくなったためUIから廃止。
      // NOT NULL制約を満たすための内部固定値（表示・参照には一切使用しない）。
      await repo.create(companion.copyWith(grade: const Value(1)));
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
      appBar: AppBar(title: Text(_isEditing ? '選手を編集' : '選手を登録')),
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
                  Center(
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Stack(
                        children: [
                          PlayerAvatar(photoPath: _photoPath, radius: 48),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: const Icon(Icons.edit, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '氏名 *'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '氏名を入力してください' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _kanaController,
                    decoration: const InputDecoration(labelText: 'ふりがな'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    initialValue: _position,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'ポジション'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('未設定')),
                      ...basketballPositions.map(
                        (p) => DropdownMenuItem(value: p, child: Text(p)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _position = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _jerseyController,
                          decoration: const InputDecoration(labelText: '背番号'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _pickBirthDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: '生年月日'),
                            child: Text(
                              _birthDate == null
                                  ? '未設定'
                                  : DateFormat('yyyy/MM/dd').format(_birthDate!),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                        : Text(_isEditing ? '更新する' : '登録する'),
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
