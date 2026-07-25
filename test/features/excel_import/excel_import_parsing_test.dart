import 'dart:typed_data';

import 'package:excel/excel.dart' as xlsx;
import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/core/services/excel_workbook.dart';
import 'package:performance_analytics/features/excel_import/domain/excel_column_mapping.dart';
import 'package:performance_analytics/features/excel_import/domain/excel_import_row.dart';

void main() {
  group('parseExcelRow', () {
    final mappings = [
      const ExcelColumnMapping(
        columnIndex: 0,
        headerLabel: '名前',
        role: ExcelColumnRole.athleteName,
      ),
      const ExcelColumnMapping(
        columnIndex: 1,
        headerLabel: '学年',
        role: ExcelColumnRole.ignore,
      ),
      const ExcelColumnMapping(
        columnIndex: 2,
        headerLabel: 'P',
        role: ExcelColumnRole.position,
      ),
      const ExcelColumnMapping(
        columnIndex: 3,
        headerLabel: '身長 cm',
        role: ExcelColumnRole.measurementItem,
        measurementItemId: 'height',
      ),
      const ExcelColumnMapping(
        columnIndex: 4,
        headerLabel: '順位',
      ),
    ];

    test('氏名・ポジション・測定値を正しく抽出する', () {
      final result = parseExcelRow(['横田向星', '2', 'G', '175', '3'], mappings);

      expect(result.athleteName, '横田向星');
      expect(result.position, 'G');
      expect(result.values, {'height': 175.0});
      expect(result.skippedCellCount, 0);
      expect(result.isEmpty, isFalse);
    });

    test('数値として解釈できないセルはスキップされ件数がカウントされる', () {
      final result = parseExcelRow(['佐藤次郎', '1', 'F', '#N/A', ''], mappings);

      expect(result.values, isEmpty);
      expect(result.skippedCellCount, 1);
    });

    test('無視列(順位)は抽出されない', () {
      final result = parseExcelRow(['選手A', '3', 'C', '160', '99'], mappings);

      expect(result.values, {'height': 160.0});
    });

    test('氏名も測定値も無い行はisEmpty=trueになる', () {
      final result = parseExcelRow(['', '', '', '', ''], mappings);
      expect(result.isEmpty, isTrue);
    });
  });

  group('ExcelWorkbook', () {
    test('シート名と行データを文字列として読み取れる（2段ヘッダー相当）', () {
      final excel = xlsx.Excel.createExcel();
      const sheetName = '原本';
      excel.rename(excel.getDefaultSheet()!, sheetName);

      excel.appendRow(sheetName, [
        null,
        null,
        xlsx.TextCellValue('名前'),
        xlsx.TextCellValue('身長'),
      ]);
      excel.appendRow(sheetName, [
        xlsx.TextCellValue('NO.'),
        xlsx.TextCellValue('学年'),
        null,
        xlsx.TextCellValue('cm'),
      ]);
      excel.appendRow(sheetName, [
        xlsx.IntCellValue(1),
        xlsx.IntCellValue(2),
        xlsx.TextCellValue('横田向星'),
        xlsx.DoubleCellValue(175.5),
      ]);

      final bytes = excel.save();
      expect(bytes, isNotNull);

      final workbook = ExcelWorkbook.fromBytes(Uint8List.fromList(bytes!));
      expect(workbook.sheetNames, contains(sheetName));

      final rows = workbook.sheetRows(sheetName);
      expect(rows.length, 3);
      expect(rows[2][2], '横田向星');
      expect(rows[2][3], '175.5');
      expect(rows[1][0], 'NO.');
    });
  });
}
