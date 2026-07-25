import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../team_session/data/supabase_team_repository.dart';
import '../../team_session/data/team_session_provider.dart';

/// チーム基本情報の編集画面。初期セットアップ（[OnboardingScreen]）で
/// 保存したチーム名を後から変更できるようにする。
/// チーム共有モードではSupabase側のチーム名も更新する。
class TeamSettingsScreen extends ConsumerStatefulWidget {
  const TeamSettingsScreen({super.key});

  @override
  ConsumerState<TeamSettingsScreen> createState() => _TeamSettingsScreenState();
}

class _TeamSettingsScreenState extends ConsumerState<TeamSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = ref.read(teamSessionProvider);
    if (session != null) {
      if (mounted) {
        setState(() {
          _teamNameController.text = session.teamName;
          _loading = false;
        });
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _teamNameController.text = prefs.getString('team_name') ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final name = _teamNameController.text.trim();
    final session = ref.read(teamSessionProvider);
    if (session != null) {
      await ref.read(teamRepositoryProvider).updateTeamName(session.teamId, name);
      await ref.read(teamSessionProvider.notifier).setSession(session.copyWith(teamName: name));
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('team_name', name);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存しました')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final canEdit = ref.watch(canEditProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('チーム設定')),
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
                    controller: _teamNameController,
                    enabled: canEdit,
                    decoration: const InputDecoration(labelText: 'チーム名 *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'チーム名を入力してください' : null,
                  ),
                  if (canEdit) ...[
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _saving ? null : _submit,
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
      ),
    );
  }
}
