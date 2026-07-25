import 'package:flutter/material.dart';

/// アプリ全体で共有するレスポンシブブレークポイント。
/// モバイル/タブレット/デスクトップの3段階でレイアウトを切り替える。
class Breakpoints {
  static const compact = 600.0; // これ未満はモバイル
  static const medium = 1024.0; // これ未満はタブレット、以上はデスクトップ
}

enum ScreenSize { compact, medium, expanded }

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  ScreenSize get screenSize {
    final w = screenWidth;
    if (w < Breakpoints.compact) return ScreenSize.compact;
    if (w < Breakpoints.medium) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  bool get isCompact => screenSize == ScreenSize.compact;
  bool get isExpanded => screenSize == ScreenSize.expanded;
}
