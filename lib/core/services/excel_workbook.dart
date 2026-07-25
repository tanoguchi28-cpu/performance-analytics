import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

/// `excel`パッケージの生API（CellValueのsealed class等）をアプリ側から
/// 隠蔽し、シート名一覧と行データを単純な文字列の2次元配列として扱えるようにする薄いラッパー。
class ExcelWorkbook {
  ExcelWorkbook._(this._excel);

  factory ExcelWorkbook.fromBytes(Uint8List bytes) {
    return ExcelWorkbook._(Excel.decodeBytes(bytes));
  }

  final Excel _excel;

  List<String> get sheetNames => _excel.tables.keys.toList();

  /// 指定シートの全行を文字列(nullable)の2次元配列として返す。
  /// 数式セルは値を評価できないため常にnullとして扱う。
  List<List<String?>> sheetRows(String sheetName) {
    final sheet = _excel.tables[sheetName];
    if (sheet == null) return [];
    return sheet.rows.map((row) {
      return row.map((cell) => _cellToString(cell?.value)).toList();
    }).toList();
  }

  static String? _cellToString(CellValue? value) {
    return switch (value) {
      null => null,
      TextCellValue v => v.value.toString().trim().isEmpty ? null : v.value.toString().trim(),
      IntCellValue v => v.value.toString(),
      DoubleCellValue v => _formatDouble(v.value),
      BoolCellValue v => v.value.toString(),
      DateCellValue v => DateFormat('yyyy-MM-dd').format(
          DateTime(v.year, v.month, v.day),
        ),
      DateTimeCellValue v => DateFormat('yyyy-MM-dd').format(v.asDateTimeLocal()),
      TimeCellValue _ => null,
      FormulaCellValue _ => null, // オフラインでは計算結果を取得できない
    };
  }

  static String _formatDouble(double v) {
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
  }
}
