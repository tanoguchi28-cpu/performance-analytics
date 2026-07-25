import 'package:flutter_test/flutter_test.dart';
import 'package:performance_analytics/features/analytics/domain/statistics_result.dart';

void main() {
  group('StatisticsResult.compute', () {
    test('チーム統計・偏差値・順位・改善率をまとめて算出する（垂直跳び, higherIsBetter=true）', () {
      final result = StatisticsResult.compute(
        athleteValue: 65,
        teamValues: [65, 60, 55, 50, 70],
        higherIsBetter: true,
        historyValues: [55, 60],
        previousValue: 60,
      );

      expect(result.mean, 60);
      expect(result.median, 60);
      expect(result.standardDeviation, closeTo(7.0710678, 1e-5));
      expect(result.deviationScore, closeTo(57.07, 0.01));
      expect(result.rank, 2); // 70のみ自分より上
      expect(result.participantCount, 5);
      expect(result.bestRecord, 65); // 過去[55,60]+今回65の中で最大
      expect(result.worstRecord, 55);
      expect(result.improvementRate, closeTo(18.1818, 1e-3)); // (65-55)/55
      expect(result.vsLastRate, closeTo(8.3333, 1e-3)); // (65-60)/60
      expect(result.vsLastYearRate, isNull);
    });

    test('タイム系項目（higherIsBetter=false）でも正しく評価される', () {
      final result = StatisticsResult.compute(
        athleteValue: 3.20, // 3/4コートスプリント: 速いほど良い
        teamValues: [3.20, 3.30, 3.40, 3.50],
        higherIsBetter: false,
        historyValues: [3.50, 3.35],
        previousValue: 3.35,
        lastYearValue: 3.60,
      );

      expect(result.rank, 1); // 自分が最速
      expect(result.bestRecord, 3.20);
      expect(result.worstRecord, 3.50);
      expect(result.improvementRate, greaterThan(0)); // 3.50→3.20は改善
      expect(result.vsLastRate, greaterThan(0)); // 3.35→3.20も改善
      expect(result.vsLastYearRate, greaterThan(0)); // 3.60→3.20も改善
    });

    test('履歴が無い（初回測定）場合は改善率・前回比がnull', () {
      final result = StatisticsResult.compute(
        athleteValue: 50,
        teamValues: [50, 45, 40],
        higherIsBetter: true,
      );

      expect(result.improvementRate, isNull);
      expect(result.vsLastRate, isNull);
      expect(result.bestRecord, 50);
      expect(result.worstRecord, 50);
    });
  });
}
