import 'excel_column_mapping.dart';

/// Excelの1データ行をマッピング設定に従って解釈した結果。
class ExcelImportRow {
  const ExcelImportRow({
    required this.athleteName,
    required this.position,
    required this.values,
    required this.skippedCellCount,
  });

  final String? athleteName;
  final String? position;

  /// measurementItemId -> 値
  final Map<String, double> values;

  /// マッピング対象だが数値として解釈できなかったセル数（#N/A等）。
  final int skippedCellCount;

  bool get isEmpty => (athleteName == null || athleteName!.isEmpty) && values.isEmpty;
}

ExcelImportRow parseExcelRow(List<String?> row, List<ExcelColumnMapping> mappings) {
  String? athleteName;
  String? position;
  final values = <String, double>{};
  var skipped = 0;

  for (final mapping in mappings) {
    if (mapping.columnIndex >= row.length) continue;
    final raw = row[mapping.columnIndex]?.trim();
    if (raw == null || raw.isEmpty) continue;

    switch (mapping.role) {
      case ExcelColumnRole.ignore:
        break;
      case ExcelColumnRole.athleteName:
        athleteName = raw;
      case ExcelColumnRole.position:
        position = raw;
      case ExcelColumnRole.measurementItem:
        final itemId = mapping.measurementItemId;
        if (itemId == null) break;
        final value = double.tryParse(raw);
        if (value == null) {
          skipped++;
        } else {
          values[itemId] = value;
        }
    }
  }

  return ExcelImportRow(
    athleteName: athleteName,
    position: position,
    values: values,
    skippedCellCount: skipped,
  );
}
