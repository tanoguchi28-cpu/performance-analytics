import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/local_database.dart';
import '../../../../shared/widgets/ability_radar_chart.dart';
import '../../../evaluation/domain/ability_profile.dart';
import '../../data/dashboard_data_service.dart';

/// ダッシュボードの「チーム能力」カード。既定では最新セッション（[profile]、
/// 呼び出し元の[dashboardDataProvider]が算出済み）を表示するが、[sessions]から
/// 別のセッションを選ぶと[teamAbilityProfileForSessionProvider]で都度再計算する。
class TeamAbilityCard extends ConsumerStatefulWidget {
  const TeamAbilityCard({super.key, required this.profile, required this.sessions});

  final AbilityProfile profile;
  final List<MeasurementSession> sessions;

  @override
  ConsumerState<TeamAbilityCard> createState() => _TeamAbilityCardState();
}

class _TeamAbilityCardState extends ConsumerState<TeamAbilityCard> {
  String? _selectedSessionId;

  @override
  void initState() {
    super.initState();
    _selectedSessionId = widget.sessions.isEmpty ? null : widget.sessions.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final isLatestSession =
        widget.sessions.isEmpty || _selectedSessionId == widget.sessions.first.id;

    final body = isLatestSession
        ? _TeamAbilityBody(profile: widget.profile)
        : ref.watch(teamAbilityProfileForSessionProvider(sessionId: _selectedSessionId!)).when(
              data: (profile) => _TeamAbilityBody(profile: profile),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('読み込みエラー: $e'),
              ),
            );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('チーム能力', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (widget.sessions.isNotEmpty)
                  DropdownButton<String>(
                    value: _selectedSessionId,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final s in widget.sessions)
                        DropdownMenuItem(
                          value: s.id,
                          child: Text(
                            s.label ?? DateFormat('yyyy/MM/dd').format(s.measurementDate),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedSessionId = v);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            body,
          ],
        ),
      ),
    );
  }
}

class _TeamAbilityBody extends StatelessWidget {
  const _TeamAbilityBody({required this.profile});

  final AbilityProfile profile;

  @override
  Widget build(BuildContext context) {
    final measured = [...profile.measuredScores]
      ..sort((a, b) => b.score!.compareTo(a.score!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: AbilityRadarChart(profile: profile, size: 220)),
        const SizedBox(height: 12),
        if (measured.isNotEmpty) ...[
          _StrengthRow(
            label: 'チームの強み',
            text: '${measured.first.category.label}（偏差値相当 ${measured.first.roundedScore}）',
            color: const Color(0xFF2E7D32),
          ),
          if (measured.length > 1)
            _StrengthRow(
              label: '改善ポイント',
              text: '${measured.last.category.label}（偏差値相当 ${measured.last.roundedScore}）',
              color: const Color(0xFFE53935),
            ),
        ],
      ],
    );
  }
}

class _StrengthRow extends StatelessWidget {
  const _StrengthRow({required this.label, required this.text, required this.color});

  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
