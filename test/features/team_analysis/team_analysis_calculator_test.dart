import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/features/team_analysis/domain/team_analysis_calculator.dart';

void main() {
  group('histogram', () {
    test('最小値〜最大値をbinCount等分して度数を数える', () {
      final bins = TeamAnalysisCalculator.histogram([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], binCount: 5);
      expect(bins.length, 5);
      expect(bins.map((b) => b.count).reduce((a, b) => a + b), 11);
    });

    test('全員同値のときは1区間にまとめる', () {
      final bins = TeamAnalysisCalculator.histogram([5, 5, 5]);
      expect(bins.length, 1);
      expect(bins.single.count, 3);
    });

    test('空リストは空を返す', () {
      expect(TeamAnalysisCalculator.histogram([]), isEmpty);
    });
  });

  group('boxPlot', () {
    test('五数要約を線形補間で算出する', () {
      final stats = TeamAnalysisCalculator.boxPlot([1, 2, 3, 4, 5, 6, 7, 8, 9])!;
      expect(stats.min, 1);
      expect(stats.median, 5);
      expect(stats.max, 9);
      expect(stats.q1, closeTo(3, 1e-9));
      expect(stats.q3, closeTo(7, 1e-9));
    });

    test('空リストはnull', () {
      expect(TeamAnalysisCalculator.boxPlot([]), isNull);
    });
  });

  group('pearsonCorrelation', () {
    test('完全な正の相関では1になる', () {
      final r = TeamAnalysisCalculator.pearsonCorrelation([1, 2, 3, 4], [10, 20, 30, 40]);
      expect(r, closeTo(1.0, 1e-9));
    });

    test('完全な負の相関では-1になる', () {
      final r = TeamAnalysisCalculator.pearsonCorrelation([1, 2, 3, 4], [40, 30, 20, 10]);
      expect(r, closeTo(-1.0, 1e-9));
    });

    test('ペアが2件未満ならnull', () {
      expect(TeamAnalysisCalculator.pearsonCorrelation([1], [1]), isNull);
    });

    test('分散が0（全員同値）ならnull', () {
      expect(TeamAnalysisCalculator.pearsonCorrelation([1, 1, 1], [1, 2, 3]), isNull);
    });
  });

  group('academicYear', () {
    test('4月以降はその年の年度', () {
      expect(TeamAnalysisCalculator.academicYear(DateTime(2026, 4, 1)), 2026);
      expect(TeamAnalysisCalculator.academicYear(DateTime(2026, 12, 31)), 2026);
    });

    test('1〜3月は前年の年度', () {
      expect(TeamAnalysisCalculator.academicYear(DateTime(2026, 3, 31)), 2025);
      expect(TeamAnalysisCalculator.academicYear(DateTime(2026, 1, 1)), 2025);
    });
  });
}
