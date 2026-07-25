import 'package:flutter/material.dart';

class AppTheme {
  static const _seedColor = Color(0xFFEA580C);

  static ThemeData light() {
    final cs = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    return _build(cs);
  }

  static ThemeData dark() {
    final cs = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    return _build(cs);
  }

  static ThemeData _build(ColorScheme cs) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: cs.primaryContainer,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// 5段階評価（新体力テスト等の得点）のグラデーションカラー。1=要改善 〜 5=優秀。
Color evaluationScoreColor(int score) {
  switch (score) {
    case 5:
      return const Color(0xFF2E7D32);
    case 4:
      return const Color(0xFF66BB6A);
    case 3:
      return const Color(0xFFFFB300);
    case 2:
      return const Color(0xFFFB8C00);
    case 1:
      return const Color(0xFFE53935);
    default:
      return const Color(0xFF9E9E9E); // 評価なし
  }
}

/// レーダーチャートの6能力カテゴリに割り当てる配色。
class AbilityColors {
  static const explosivePower = Color(0xFFEA580C); // 瞬発力
  static const muscularPower = Color(0xFF8E24AA); // 筋パワー
  static const muscularEndurance = Color(0xFF1E88E5); // 筋持久力
  static const cardioEndurance = Color(0xFF00897B); // 全身持久力
  static const agility = Color(0xFFF9A825); // 敏捷性
  static const flexibility = Color(0xFF43A047); // 柔軟性
}
