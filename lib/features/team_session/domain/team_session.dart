import 'staff_role.dart';

/// この端末で選択されているチーム共有セッション。
/// オンボーディングでチームに参加/新規登録した際に確定し、端末に永続化される。
class TeamSession {
  const TeamSession({
    required this.teamId,
    required this.teamName,
    required this.role,
    this.athleteId,
    this.athleteName,
  });

  final String teamId;
  final String teamName;
  final StaffRole role;

  /// role==playerのときのみ非null。紐付いた[Athlete.id]。
  final String? athleteId;

  /// role==playerのときのみ非null。表示用にキャッシュした選手名。
  final String? athleteName;

  TeamSession copyWith({String? teamName}) {
    return TeamSession(
      teamId: teamId,
      teamName: teamName ?? this.teamName,
      role: role,
      athleteId: athleteId,
      athleteName: athleteName,
    );
  }
}
