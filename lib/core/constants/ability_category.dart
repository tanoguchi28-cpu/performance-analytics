/// レーダーチャートの6能力カテゴリ。他競技への展開時もこの6分類を基本とする。
enum AbilityCategory {
  explosivePower('瞬発力'),
  muscularPower('筋パワー'),
  muscularEndurance('筋持久力'),
  cardioEndurance('全身持久力'),
  agility('敏捷性'),
  flexibility('柔軟性'),
  none('対象外');

  const AbilityCategory(this.label);
  final String label;
}
