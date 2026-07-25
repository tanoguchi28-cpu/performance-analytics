import 'package:flutter/material.dart';

/// 横スクロール可能な単一選択チップ群（学年・ポジション等の絞り込みUIで使う）。
class FilterChipGroup<T> extends StatelessWidget {
  const FilterChipGroup({
    super.key,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> options;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final option in options)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(labelBuilder(option)),
                  selected: value == option,
                  onSelected: (_) => onChanged(option),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
