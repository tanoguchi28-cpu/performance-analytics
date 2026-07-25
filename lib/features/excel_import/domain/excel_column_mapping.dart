/// Excelの1列をアプリのどのフィールドに割り当てるか。
enum ExcelColumnRole {
  ignore('無視'),
  athleteName('氏名'),
  position('ポジション'),
  measurementItem('測定項目');

  const ExcelColumnRole(this.label);
  final String label;
}

/// Excelの列インデックスとアプリ側フィールドの対応付け。
/// [role]が[ExcelColumnRole.measurementItem]の場合のみ[measurementItemId]を持つ。
class ExcelColumnMapping {
  const ExcelColumnMapping({
    required this.columnIndex,
    required this.headerLabel,
    this.role = ExcelColumnRole.ignore,
    this.measurementItemId,
  });

  final int columnIndex;
  final String headerLabel;
  final ExcelColumnRole role;
  final String? measurementItemId;

  ExcelColumnMapping copyWith({
    ExcelColumnRole? role,
    String? measurementItemId,
    bool clearMeasurementItemId = false,
  }) {
    return ExcelColumnMapping(
      columnIndex: columnIndex,
      headerLabel: headerLabel,
      role: role ?? this.role,
      measurementItemId:
          clearMeasurementItemId ? null : (measurementItemId ?? this.measurementItemId),
    );
  }
}
