import 'package:flutter/material.dart';

import '../../domain/team_analysis_models.dart';

/// 学年別・ポジション別などグループごとの箱ひげ図を横並びで表示する。
class BoxPlotChart extends StatelessWidget {
  const BoxPlotChart({super.key, required this.groups, required this.unit});

  final List<GroupBoxPlot> groups;
  final String unit;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('データがありません')),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final globalMin = groups.map((g) => g.stats.min).reduce((a, b) => a < b ? a : b);
    final globalMax = groups.map((g) => g.stats.max).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 220,
      child: CustomPaint(
        size: Size.infinite,
        painter: _BoxPlotPainter(
          groups: groups,
          globalMin: globalMin,
          globalMax: globalMax,
          boxColor: cs.primary,
          labelColor: cs.onSurfaceVariant,
          textColor: DefaultTextStyle.of(context).style.color ?? cs.onSurface,
        ),
      ),
    );
  }
}

class _BoxPlotPainter extends CustomPainter {
  _BoxPlotPainter({
    required this.groups,
    required this.globalMin,
    required this.globalMax,
    required this.boxColor,
    required this.labelColor,
    required this.textColor,
  });

  final List<GroupBoxPlot> groups;
  final double globalMin;
  final double globalMax;
  final Color boxColor;
  final Color labelColor;
  final Color textColor;

  static const _labelHeight = 34.0;
  static const _topPadding = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final plotHeight = size.height - _labelHeight - _topPadding;
    final range = (globalMax - globalMin) == 0 ? 1.0 : (globalMax - globalMin);
    final padded = range * 0.15;
    final scaleMin = globalMin - padded;
    final scaleMax = globalMax + padded;

    double yFor(double value) {
      final t = (value - scaleMin) / (scaleMax - scaleMin);
      return _topPadding + plotHeight * (1 - t);
    }

    final slotWidth = size.width / groups.length;
    final boxWidth = (slotWidth * 0.4).clamp(12.0, 48.0);

    final linePaint = Paint()
      ..color = boxColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = boxColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < groups.length; i++) {
      final group = groups[i];
      final cx = slotWidth * i + slotWidth / 2;
      final stats = group.stats;

      // ひげ（最小〜最大）
      canvas.drawLine(Offset(cx, yFor(stats.min)), Offset(cx, yFor(stats.max)), linePaint);
      // ひげのキャップ
      canvas.drawLine(
        Offset(cx - boxWidth / 4, yFor(stats.min)),
        Offset(cx + boxWidth / 4, yFor(stats.min)),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx - boxWidth / 4, yFor(stats.max)),
        Offset(cx + boxWidth / 4, yFor(stats.max)),
        linePaint,
      );

      // 箱（Q1〜Q3）
      final boxRect = Rect.fromLTRB(
        cx - boxWidth / 2,
        yFor(stats.q3),
        cx + boxWidth / 2,
        yFor(stats.q1),
      );
      canvas.drawRect(boxRect, fillPaint);
      canvas.drawRect(boxRect, linePaint);

      // 中央値
      canvas.drawLine(
        Offset(cx - boxWidth / 2, yFor(stats.median)),
        Offset(cx + boxWidth / 2, yFor(stats.median)),
        linePaint..strokeWidth = 2.5,
      );
      linePaint.strokeWidth = 2;

      // ラベル（グループ名 + n数）
      final label = '${group.label}\n(n=${group.count})';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(fontSize: 11, color: textColor),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: slotWidth);
      tp.paint(canvas, Offset(cx - tp.width / 2, size.height - _labelHeight + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _BoxPlotPainter oldDelegate) {
    return oldDelegate.groups != groups ||
        oldDelegate.globalMin != globalMin ||
        oldDelegate.globalMax != globalMax;
  }
}
