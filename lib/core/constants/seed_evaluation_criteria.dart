import 'package:drift/drift.dart';

import '../database/local_database.dart';

/// 高校男子(15〜18歳)向けの評価基準。
///
/// 長座体前屈・上体おこしは文部科学省新体力テストの評価領域に対応するが、
/// ここでの数値はチームから共有された「県優勝レベルの目標値」をレベル5(優秀)の
/// 基準として、そこから逆算した5段階バンドであり、文部科学省が公表する
/// 得点表そのものではない。3/4コートスプリント・レーンアジリティー・反復横跳び・
/// 垂直跳び・チェストパスも同様にチーム提供の目標値をレベル5の基準としている。
/// シャトルランは「その年の測定結果から算出する」運用（固定目標値なし）との
/// ことなので、暫定的な固定バンドを設定している（将来的には偏差値・順位ベースの
/// 動的評価に置き換えるのが望ましい）。懸垂・P-upは参考にできる基準値が無いため
/// 評価基準を設定していない（評価なし）。
///
/// 運用開始前に必ず「評価基準設定」画面で実際のチーム・大会基準に
/// 合わせて調整すること。
const _seedGender = 'male';
const _seedAgeMin = 15;
const _seedAgeMax = 18;

class _CriteriaSeed {
  const _CriteriaSeed(this.itemKey, this.position, this.name, this.bandsHighToLow);

  final String itemKey;

  /// null = ポジション共通。
  final String? position;
  final String name;

  /// レベル5(最高)→レベル1(要改善)の順で [下限, 上限] を並べたもの。
  /// null は「その方向に上限/下限なし」を意味する。
  final List<(double?, double?)> bandsHighToLow;

  String get id => 'crit_$itemKey${position == null ? '' : '_$position'}';
}

// 「県優勝レベルの目標値」(チーム提供)をレベル5の基準とし、
// 上位比率(93%/85%/75%)で残りのレベルを逆算した参考バンド。
final _seeds = <_CriteriaSeed>[
  _CriteriaSeed('sit_and_reach', null, '高校男子 基準（チーム目標値ベース）', [
    (60, null),
    (56, 59),
    (51, 55),
    (45, 50),
    (null, 44),
  ]),
  _CriteriaSeed('three_quarter_sprint', 'G', '高校男子 G 基準（チーム目標値ベース）', [
    (null, 3.20),
    (3.21, 3.36),
    (3.37, 3.52),
    (3.53, 3.78),
    (3.79, null),
  ]),
  _CriteriaSeed('three_quarter_sprint', 'F', '高校男子 F 基準（チーム目標値ベース）', [
    (null, 3.25),
    (3.26, 3.41),
    (3.42, 3.58),
    (3.59, 3.84),
    (3.85, null),
  ]),
  _CriteriaSeed('three_quarter_sprint', 'C', '高校男子 C 基準（チーム目標値ベース）', [
    (null, 3.30),
    (3.31, 3.47),
    (3.48, 3.63),
    (3.64, 3.89),
    (3.90, null),
  ]),
  _CriteriaSeed('lane_agility', 'G', '高校男子 G 基準（チーム目標値ベース）', [
    (null, 10.90),
    (10.91, 11.45),
    (11.46, 11.99),
    (12.00, 12.86),
    (12.87, null),
  ]),
  _CriteriaSeed('lane_agility', 'F', '高校男子 F 基準（チーム目標値ベース）', [
    (null, 10.90),
    (10.91, 11.45),
    (11.46, 11.99),
    (12.00, 12.86),
    (12.87, null),
  ]),
  _CriteriaSeed('lane_agility', 'C', '高校男子 C 基準（チーム目標値ベース）', [
    (null, 11.00),
    (11.01, 11.55),
    (11.56, 12.10),
    (12.11, 12.98),
    (12.99, null),
  ]),
  _CriteriaSeed('side_step', 'G', '高校男子 G 基準（チーム目標値ベース）', [
    (65, null),
    (60, 64),
    (55, 59),
    (49, 54),
    (null, 48),
  ]),
  _CriteriaSeed('side_step', 'F', '高校男子 F 基準（チーム目標値ベース）', [
    (60, null),
    (56, 59),
    (51, 55),
    (45, 50),
    (null, 44),
  ]),
  _CriteriaSeed('side_step', 'C', '高校男子 C 基準（チーム目標値ベース）', [
    (58, null),
    (54, 57),
    (49, 53),
    (44, 48),
    (null, 43),
  ]),
  _CriteriaSeed('vertical_jump', 'G', '高校男子 G 基準（チーム目標値ベース）', [
    (65, null),
    (60, 64),
    (55, 59),
    (49, 54),
    (null, 48),
  ]),
  _CriteriaSeed('vertical_jump', 'F', '高校男子 F 基準（チーム目標値ベース）', [
    (65, null),
    (60, 64),
    (55, 59),
    (49, 54),
    (null, 48),
  ]),
  _CriteriaSeed('vertical_jump', 'C', '高校男子 C 基準（チーム目標値ベース）', [
    (64, null),
    (60, 63),
    (54, 59),
    (48, 53),
    (null, 47),
  ]),
  _CriteriaSeed('chest_pass', 'G', '高校男子 G 基準（チーム目標値ベース）', [
    (1465, null),
    (1362, 1464),
    (1245, 1361),
    (1099, 1244),
    (null, 1098),
  ]),
  _CriteriaSeed('chest_pass', 'F', '高校男子 F 基準（チーム目標値ベース）', [
    (1500, null),
    (1395, 1499),
    (1275, 1394),
    (1125, 1274),
    (null, 1124),
  ]),
  _CriteriaSeed('chest_pass', 'C', '高校男子 C 基準（チーム目標値ベース）', [
    (1500, null),
    (1395, 1499),
    (1275, 1394),
    (1125, 1274),
    (null, 1124),
  ]),
  _CriteriaSeed('sit_up', 'G', '高校男子 G 基準（チーム目標値ベース）', [
    (35, null),
    (33, 34),
    (30, 32),
    (26, 29),
    (null, 25),
  ]),
  _CriteriaSeed('sit_up', 'F', '高校男子 F 基準（チーム目標値ベース）', [
    (35, null),
    (33, 34),
    (30, 32),
    (26, 29),
    (null, 25),
  ]),
  _CriteriaSeed('sit_up', 'C', '高校男子 C 基準（チーム目標値ベース）', [
    (33, null),
    (31, 32),
    (28, 30),
    (25, 27),
    (null, 24),
  ]),
  // シャトルランはチーム内で「その年の測定結果から算出」する運用のため
  // 固定目標値の提供がなかった。当面は暫定バンドを置く。
  _CriteriaSeed('shuttle_run', null, '高校男子 基準（暫定値・要確認）', [
    (110, null),
    (95, 109),
    (80, 94),
    (60, 79),
    (null, 59),
  ]),
];

final defaultEvaluationCriteria = <EvaluationCriteriaCompanion>[
  for (final seed in _seeds)
    EvaluationCriteriaCompanion.insert(
      id: seed.id,
      name: seed.name,
      itemKey: seed.itemKey,
      gender: const Value(_seedGender),
      ageGroupMin: const Value(_seedAgeMin),
      ageGroupMax: const Value(_seedAgeMax),
      position: Value(seed.position),
    ),
];

final defaultScoreBands = <ScoreBandsCompanion>[
  for (final seed in _seeds)
    for (var level = 0; level < seed.bandsHighToLow.length; level++)
      ScoreBandsCompanion.insert(
        id: 'band_${seed.id}_${5 - level}',
        criteriaId: seed.id,
        minValue: Value(seed.bandsHighToLow[level].$1),
        maxValue: Value(seed.bandsHighToLow[level].$2),
        score: 5 - level,
      ),
];
