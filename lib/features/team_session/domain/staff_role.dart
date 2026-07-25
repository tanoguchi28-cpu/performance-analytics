/// チーム内での役割。閲覧・編集できるデータの範囲を決める。
enum StaffRole {
  headCoach('監督'),
  coach('コーチ'),
  trainer('トレーナー'),
  studentStaff('学生スタッフ'),
  player('選手');

  const StaffRole(this.label);
  final String label;

  /// 全データの閲覧・編集が可能か（監督・コーチ・トレーナーのみ）。
  bool get canEdit => this == headCoach || this == coach || this == trainer;

  /// 選手本人か（自分の測定記録とチーム分析のみ閲覧可能）。
  bool get isPlayer => this == player;
}
