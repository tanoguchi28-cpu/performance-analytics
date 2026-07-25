import 'package:drift/drift.dart';

import '../database/local_database.dart';
import 'ability_category.dart';

/// 初期14測定項目。あくまで初期値であり、実際の運用では
/// 測定項目管理画面から自由に追加・編集・無効化できる。
///
/// 項目名・並び順は実運用中のExcel原本（体力測定データ）の列構成に合わせてある。
/// なお原本の当該列見出しは現状「20mスプリント」表記だが、正式名称は
/// 「3/4コートスプリント」（原本側の表記更新が未対応のだけ）とのことなので、
/// アプリ側は正式名称で登録している。
/// 「懸垂」「P-up」は実データに存在する項目として追加したが、
/// 参考にできる評価基準がまだ無いため能力カテゴリは対象外(none)としている。
final defaultMeasurementItems = <MeasurementItemsCompanion>[
  MeasurementItemsCompanion.insert(
    id: 'height',
    key: 'height',
    name: '身長',
    unit: 'cm',
    abilityCategory: AbilityCategory.none,
    sortOrder: const Value(1),
  ),
  MeasurementItemsCompanion.insert(
    id: 'weight',
    key: 'weight',
    name: '体重',
    unit: 'kg',
    abilityCategory: AbilityCategory.none,
    sortOrder: const Value(2),
  ),
  MeasurementItemsCompanion.insert(
    id: 'standing_reach',
    key: 'standing_reach',
    name: 'スタンディングリーチ',
    unit: 'cm',
    abilityCategory: AbilityCategory.none,
    sortOrder: const Value(3),
  ),
  MeasurementItemsCompanion.insert(
    id: 'wingspan',
    key: 'wingspan',
    name: 'ウィングスパン',
    unit: 'cm',
    abilityCategory: AbilityCategory.none,
    sortOrder: const Value(4),
  ),
  MeasurementItemsCompanion.insert(
    id: 'sit_and_reach',
    key: 'sit_and_reach',
    name: '長座体前屈',
    unit: 'cm',
    abilityCategory: AbilityCategory.flexibility,
    sortOrder: const Value(5),
  ),
  MeasurementItemsCompanion.insert(
    id: 'three_quarter_sprint',
    key: 'three_quarter_sprint',
    name: '3/4コートスプリント',
    unit: 'sec',
    higherIsBetter: const Value(false),
    abilityCategory: AbilityCategory.explosivePower,
    sortOrder: const Value(6),
  ),
  MeasurementItemsCompanion.insert(
    id: 'lane_agility',
    key: 'lane_agility',
    name: 'レーンアジリティー',
    unit: 'sec',
    higherIsBetter: const Value(false),
    abilityCategory: AbilityCategory.agility,
    sortOrder: const Value(7),
  ),
  MeasurementItemsCompanion.insert(
    id: 'side_step',
    key: 'side_step',
    name: '反復横跳び',
    unit: '回',
    abilityCategory: AbilityCategory.agility,
    sortOrder: const Value(8),
  ),
  MeasurementItemsCompanion.insert(
    id: 'vertical_jump',
    key: 'vertical_jump',
    name: '垂直跳び',
    unit: 'cm',
    abilityCategory: AbilityCategory.explosivePower,
    sortOrder: const Value(9),
  ),
  MeasurementItemsCompanion.insert(
    id: 'chest_pass',
    key: 'chest_pass',
    name: 'チェストパス',
    unit: 'cm',
    abilityCategory: AbilityCategory.muscularPower,
    sortOrder: const Value(10),
  ),
  MeasurementItemsCompanion.insert(
    id: 'sit_up',
    key: 'sit_up',
    name: '上体おこし',
    unit: '回',
    abilityCategory: AbilityCategory.muscularEndurance,
    sortOrder: const Value(11),
  ),
  MeasurementItemsCompanion.insert(
    id: 'shuttle_run',
    key: 'shuttle_run',
    name: 'シャトルラン',
    unit: '回',
    abilityCategory: AbilityCategory.cardioEndurance,
    sortOrder: const Value(12),
  ),
  MeasurementItemsCompanion.insert(
    id: 'pull_up',
    key: 'pull_up',
    name: '懸垂',
    unit: '回',
    abilityCategory: AbilityCategory.none,
    sortOrder: const Value(13),
  ),
  MeasurementItemsCompanion.insert(
    id: 'push_up',
    key: 'push_up',
    name: 'P-up',
    unit: '回',
    abilityCategory: AbilityCategory.none,
    sortOrder: const Value(14),
  ),
];
