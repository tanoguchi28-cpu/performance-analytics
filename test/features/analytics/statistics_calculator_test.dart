import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/features/analytics/domain/statistics_calculator.dart';

void main() {
  group('mean', () {
    test('算術平均を計算する', () {
      expect(StatisticsCalculator.mean([2, 4, 6]), 4);
    });

    test('空リストはArgumentError', () {
      expect(() => StatisticsCalculator.mean([]), throwsArgumentError);
    });
  });

  group('median', () {
    test('要素数が奇数のとき中央の値を返す', () {
      expect(StatisticsCalculator.median([3, 1, 2]), 2);
    });

    test('要素数が偶数のとき中央2値の平均を返す', () {
      expect(StatisticsCalculator.median([1, 2, 3, 4]), 2.5);
    });
  });

  group('standardDeviation', () {
    test('母集団標準偏差を計算する（既知の例: 平均5, 標準偏差2）', () {
      final values = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];
      expect(StatisticsCalculator.standardDeviation(values), closeTo(2.0, 1e-9));
    });

    test('要素が1件のときは0', () {
      expect(StatisticsCalculator.standardDeviation([42]), 0);
    });
  });

  group('deviationScore', () {
    test('平均と同値なら偏差値50', () {
      final score = StatisticsCalculator.deviationScore(
        value: 60,
        mean: 60,
        standardDeviation: 7.07,
        higherIsBetter: true,
      );
      expect(score, 50);
    });

    test('higherIsBetter=trueでは平均より高いほど偏差値も高い', () {
      final score = StatisticsCalculator.deviationScore(
        value: 67.07,
        mean: 60,
        standardDeviation: 7.07,
        higherIsBetter: true,
      );
      expect(score, closeTo(60, 0.1));
    });

    test('higherIsBetter=false（タイム系）では平均より高い値ほど偏差値が下がる', () {
      final score = StatisticsCalculator.deviationScore(
        value: 67.07,
        mean: 60,
        standardDeviation: 7.07,
        higherIsBetter: false,
      );
      expect(score, closeTo(40, 0.1));
    });

    test('標準偏差0のときは常に50', () {
      final score = StatisticsCalculator.deviationScore(
        value: 999,
        mean: 60,
        standardDeviation: 0,
        higherIsBetter: true,
      );
      expect(score, 50);
    });
  });

  group('competitiveRank', () {
    const values = [10.0, 20.0, 20.0, 30.0];

    test('higherIsBetter=trueでは値が大きいほど上位、同値は同順位', () {
      expect(
        StatisticsCalculator.competitiveRank(values: values, value: 30, higherIsBetter: true),
        1,
      );
      expect(
        StatisticsCalculator.competitiveRank(values: values, value: 20, higherIsBetter: true),
        2,
      );
      expect(
        StatisticsCalculator.competitiveRank(values: values, value: 10, higherIsBetter: true),
        4,
      );
    });

    test('higherIsBetter=false（タイム系）では値が小さいほど上位', () {
      expect(
        StatisticsCalculator.competitiveRank(values: values, value: 10, higherIsBetter: false),
        1,
      );
      expect(
        StatisticsCalculator.competitiveRank(values: values, value: 30, higherIsBetter: false),
        4,
      );
    });
  });

  group('percentChange', () {
    test('higherIsBetter=trueでは値の増加が正の改善率になる', () {
      final rate = StatisticsCalculator.percentChange(from: 100, to: 110, higherIsBetter: true);
      expect(rate, closeTo(10, 1e-9));
    });

    test('higherIsBetter=false（タイム系）では値の減少が正の改善率になる', () {
      final rate = StatisticsCalculator.percentChange(from: 100, to: 90, higherIsBetter: false);
      expect(rate, closeTo(10, 1e-9));
    });

    test('fromがnullならnullを返す', () {
      expect(StatisticsCalculator.percentChange(from: null, to: 90, higherIsBetter: true), isNull);
    });

    test('fromが0ならnullを返す（ゼロ除算回避）', () {
      expect(StatisticsCalculator.percentChange(from: 0, to: 90, higherIsBetter: true), isNull);
    });
  });
}
