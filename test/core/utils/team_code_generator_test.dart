import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/core/utils/team_code_generator.dart';

void main() {
  group('TeamCodeGenerator.generate', () {
    test('8桁のコードを生成する', () {
      final code = TeamCodeGenerator.generate();
      expect(code.length, 8);
    });

    test('紛らわしい文字(0/O/1/I/L)を含まない', () {
      for (var i = 0; i < 200; i++) {
        final code = TeamCodeGenerator.generate();
        expect(code.contains(RegExp('[0O1IL]')), isFalse, reason: 'code=$code');
      }
    });

    test('英大文字・数字のみで構成される', () {
      final code = TeamCodeGenerator.generate();
      expect(RegExp(r'^[A-Z0-9]+$').hasMatch(code), isTrue);
    });

    test('連続生成でほぼ一意になる(統計的な衝突なしを確認)', () {
      final codes = {for (var i = 0; i < 1000; i++) TeamCodeGenerator.generate()};
      expect(codes.length, 1000);
    });
  });
}
