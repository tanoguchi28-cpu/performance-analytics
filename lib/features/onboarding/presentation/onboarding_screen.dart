import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/local_database.dart';
import '../../../shared/providers/supabase_provider.dart';
import '../../athletes/data/supabase_athlete_repository.dart';
import '../../team_session/data/team_session_provider.dart';
import '../../team_session/data/supabase_team_repository.dart';
import '../../team_session/domain/staff_role.dart';
import '../../team_session/domain/team.dart';
import '../../team_session/domain/team_session.dart';

enum _Step { choice, createName, createResult, joinCode, role, playerRoster }

enum _Path { create, join }

/// 初回起動時に表示するチーム参加ウィザード。
/// チーム新規登録 or チームIDで参加 → （新規登録ならID発行）→ 種別選択 →
/// （選手ならチーム名簿から自分を選択）の順で進み、[TeamSession]を確定する。
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.fetchRoster});

  /// 選手選択時の名簿取得処理。テストでSupabase接続無しに差し替えられるよう
  /// 差し込み可能にしている。未指定時は実際のチームのSupabase選手一覧を取得する。
  final Future<List<Athlete>> Function(WidgetRef ref, String teamId)? fetchRoster;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Step _step = _Step.choice;
  _Path? _path;
  bool _busy = false;
  String? _errorText;

  final _teamNameController = TextEditingController();
  final _joinCodeController = TextEditingController();
  final _rosterSearchController = TextEditingController();

  Team? _team;
  StaffRole? _selectedRole;
  List<Athlete> _roster = const [];
  bool _rosterLoading = false;

  @override
  void dispose() {
    _teamNameController.dispose();
    _joinCodeController.dispose();
    _rosterSearchController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    final name = _teamNameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'チーム名を入力してください');
      return;
    }
    setState(() {
      _busy = true;
      _errorText = null;
    });
    try {
      final team = await ref.read(teamRepositoryProvider).createTeam(name);
      if (!mounted) return;
      setState(() {
        _team = team;
        _busy = false;
        _step = _Step.createResult;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _errorText = 'チーム登録に失敗しました。通信環境を確認してもう一度お試しください';
      });
    }
  }

  Future<void> _joinTeam() async {
    final code = _joinCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorText = 'チームIDを入力してください');
      return;
    }
    setState(() {
      _busy = true;
      _errorText = null;
    });
    try {
      final team = await ref.read(teamRepositoryProvider).findTeam(code);
      if (!mounted) return;
      if (team == null) {
        setState(() {
          _busy = false;
          _errorText = 'IDが見つかりません';
        });
        return;
      }
      setState(() {
        _team = team;
        _busy = false;
        _step = _Step.role;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _errorText = 'チーム検索に失敗しました。通信環境を確認してもう一度お試しください';
      });
    }
  }

  Future<void> _selectRole(StaffRole role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('この種別でよろしいですか？'),
        content: Text('「${role.label}」として参加します。'),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('キャンセル')),
          FilledButton(onPressed: () => context.pop(true), child: const Text('はい')),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    if (role == StaffRole.player) {
      setState(() {
        _selectedRole = role;
        _step = _Step.playerRoster;
        _rosterLoading = true;
      });
      final fetch = widget.fetchRoster ??
          (ref, teamId) => SupabaseAthleteRepository(ref.read(supabaseProvider), teamId).getAll();
      final roster = await fetch(ref, _team!.id);
      if (!mounted) return;
      setState(() {
        _roster = roster;
        _rosterLoading = false;
      });
      return;
    }

    setState(() => _selectedRole = role);
    await _finish();
  }

  Future<void> _confirmPlayer(Athlete athlete) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ご本人ですか？'),
        content: Text(
          '${athlete.name}'
          '${athlete.jerseyNumber != null ? ' #${athlete.jerseyNumber}' : ''}',
        ),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('ちがう')),
          FilledButton(onPressed: () => context.pop(true), child: const Text('はい')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _finish(athlete: athlete);
  }

  Future<void> _finish({Athlete? athlete}) async {
    final session = TeamSession(
      teamId: _team!.id,
      teamName: _team!.name,
      role: _selectedRole!,
      athleteId: athlete?.id,
      athleteName: athlete?.name,
    );
    await ref.read(teamSessionProvider.notifier).setSession(session);
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(child: _buildStep(context)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case _Step.choice:
        return _buildChoiceStep(context);
      case _Step.createName:
        return _buildCreateNameStep(context);
      case _Step.createResult:
        return _buildCreateResultStep(context);
      case _Step.joinCode:
        return _buildJoinCodeStep(context);
      case _Step.role:
        return _buildRoleStep(context);
      case _Step.playerRoster:
        return _buildPlayerRosterStep(context);
    }
  }

  Widget _buildChoiceStep(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('ようこそ', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'チームを新規登録するか、発行済みのチームIDで参加してください',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () => setState(() {
            _path = _Path.create;
            _errorText = null;
            _step = _Step.createName;
          }),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('新規チーム登録（代表者の方）'),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => setState(() {
            _path = _Path.join;
            _errorText = null;
            _step = _Step.joinCode;
          }),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('チームIDで参加'),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateNameStep(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('新規チーム登録', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('チーム名を入力してください', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        TextField(
          controller: _teamNameController,
          decoration: InputDecoration(labelText: 'チーム名', errorText: _errorText),
          autofocus: true,
        ),
        const SizedBox(height: 24),
        _buildBottomControls(
          onBack: () => setState(() {
            _step = _Step.choice;
            _errorText = null;
          }),
          onNext: _busy ? null : _createTeam,
          busy: _busy,
        ),
      ],
    );
  }

  Widget _buildCreateResultStep(BuildContext context) {
    final code = _team!.id;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('チームIDが発行されました', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'このIDを他のスタッフ・選手に共有してください',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  code,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  tooltip: 'コピー',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('チームIDをコピーしました')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => setState(() => _step = _Step.role),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('次へ（自分の種別を選択）'),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinCodeStep(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('チームIDで参加', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('代表者から共有されたチームIDを入力してください', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        TextField(
          controller: _joinCodeController,
          decoration: InputDecoration(labelText: 'チームID', errorText: _errorText),
          textCapitalization: TextCapitalization.characters,
          autofocus: true,
        ),
        const SizedBox(height: 24),
        _buildBottomControls(
          onBack: () => setState(() {
            _step = _Step.choice;
            _errorText = null;
          }),
          onNext: _busy ? null : _joinTeam,
          busy: _busy,
        ),
      ],
    );
  }

  Widget _buildRoleStep(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('あなたの種別を選択してください', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          '種別によって閲覧・編集できるデータの範囲が変わります',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        for (final role in StaffRole.values) ...[
          Card(
            child: ListTile(
              title: Text(role.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectRole(role),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (_path == _Path.join) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => setState(() {
              _step = _Step.joinCode;
              _errorText = null;
            }),
            child: const Text('戻る'),
          ),
        ],
      ],
    );
  }

  Widget _buildPlayerRosterStep(BuildContext context) {
    if (_rosterLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final query = _rosterSearchController.text.trim();
    final filtered =
        query.isEmpty ? _roster : _roster.where((a) => a.name.contains(query)).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('自分の名前を選択してください', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        TextField(
          controller: _rosterSearchController,
          decoration: const InputDecoration(labelText: '氏名で検索', prefixIcon: Icon(Icons.search)),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        if (_roster.isEmpty)
          _buildRosterEmptyState(context)
        else if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('該当する選手がいません')),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final athlete = filtered[i];
                return Card(
                  child: ListTile(
                    title: Text(athlete.name),
                    subtitle: Text([
                      if (athlete.position != null) athlete.position!,
                      if (athlete.jerseyNumber != null) '#${athlete.jerseyNumber}',
                    ].join(' / ')),
                    onTap: () => _confirmPlayer(athlete),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => setState(() => _step = _Step.role),
          child: const Text('戻る'),
        ),
      ],
    );
  }

  Widget _buildRosterEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'まだあなたの名前が選手として登録されていません。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '監督・コーチに選手登録を依頼してから、もう一度お試しください。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _step = _Step.role),
                  child: const Text('戻る'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _team = null;
                    _selectedRole = null;
                    _path = null;
                    _joinCodeController.clear();
                    _teamNameController.clear();
                    _errorText = null;
                    _step = _Step.choice;
                  }),
                  child: const Text('チームIDを変更'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls({
    required VoidCallback onBack,
    required VoidCallback? onNext,
    required bool busy,
  }) {
    return Row(
      children: [
        OutlinedButton(onPressed: busy ? null : onBack, child: const Text('戻る')),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: onNext,
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('次へ'),
          ),
        ),
      ],
    );
  }
}
