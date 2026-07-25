import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/local_database.dart';
import '../../../shared/widgets/ability_radar_chart.dart';
import '../../../shared/widgets/confirm_delete_dialog.dart';
import '../../../shared/widgets/player_avatar.dart';
import '../../evaluation/data/ability_profile_service.dart';
import '../../evaluation/domain/ability_profile.dart';
import '../../measurements/data/local_measurement_repository.dart';
import '../../team_session/data/team_session_provider.dart';
import '../data/local_athlete_repository.dart';

class _ProfileData {
  const _ProfileData({required this.athlete, required this.latestSessionId});

  final Athlete athlete;
  final String? latestSessionId;
}

/// 選手プロフィールの簡易表示。
/// 測定結果推移・ランキング・PDF出力等はフェーズ10（選手個人ページ）で追加する。
class AthleteDetailScreen extends ConsumerWidget {
  const AthleteDetailScreen({super.key, required this.athleteId});

  final String athleteId;

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final athlete = await ref.read(athleteRepositoryProvider).getById(athleteId);
    final athleteName = athlete?.name ?? 'この選手';
    if (!context.mounted) return;

    final confirmed = await confirmDelete(
      context,
      title: '選手を削除しますか？',
      message: '「$athleteName」を削除します。この選手の測定記録もすべて削除され、'
          'この操作は取り消せません。',
    );
    if (!confirmed) return;

    await ref.read(athleteRepositoryProvider).delete(athleteId);
    if (context.mounted) context.pop();
  }

  Future<_ProfileData> _load(WidgetRef ref) async {
    final athleteRepo = ref.read(athleteRepositoryProvider);
    final measurementRepo = ref.read(measurementRepositoryProvider);

    final results = await Future.wait([
      athleteRepo.getById(athleteId),
      measurementRepo.getSessions(),
    ]);
    final athlete = results[0] as Athlete?;
    final sessions = results[1] as List<MeasurementSession>;
    if (athlete == null) {
      throw StateError('選手が見つかりません');
    }
    return _ProfileData(
      athlete: athlete,
      latestSessionId: sessions.isEmpty ? null : sessions.first.id,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = ref.watch(canEditProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('選手プロフィール'),
        actions: [
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: '編集',
              onPressed: () => context.push('/athletes/$athleteId/edit'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '削除',
              onPressed: () => _confirmAndDelete(context, ref),
            ),
          ],
        ],
      ),
      body: FutureBuilder<_ProfileData>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final data = snapshot.data!;
          final athlete = data.athlete;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  PlayerAvatar(photoPath: athlete.photoPath, radius: 56),
                  const SizedBox(height: 16),
                  Text(athlete.name, style: Theme.of(context).textTheme.headlineSmall),
                  if (athlete.kana != null)
                    Text(athlete.kana!, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _InfoRow(label: 'ポジション', value: athlete.position ?? '未設定'),
                          _InfoRow(
                            label: '背番号',
                            value: athlete.jerseyNumber?.toString() ?? '未設定',
                          ),
                          _InfoRow(
                            label: '生年月日',
                            value: athlete.birthDate == null
                                ? '未設定'
                                : DateFormat('yyyy/MM/dd').format(athlete.birthDate!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('能力レーダー', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          if (data.latestSessionId == null)
                            const AbilityRadarChart(profile: AbilityProfile([]))
                          else
                            _AbilityRadarSection(
                              athleteId: athleteId,
                              sessionId: data.latestSessionId!,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.assignment_outlined),
                    label: const Text('選手ページを見る（推移・AI分析・PDF出力）'),
                    onPressed: () => context.push('/athletes/$athleteId/report'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AbilityRadarSection extends ConsumerWidget {
  const _AbilityRadarSection({required this.athleteId, required this.sessionId});

  final String athleteId;
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(
      athleteAbilityProfileProvider(athleteId: athleteId, sessionId: sessionId),
    );

    return profileAsync.when(
      data: (profile) => AbilityRadarChart(profile: profile),
      loading: () => const SizedBox(
        width: 260,
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, __) => SizedBox(
        width: 260,
        height: 100,
        child: Center(child: Text('評価の読み込みに失敗しました: $e')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
