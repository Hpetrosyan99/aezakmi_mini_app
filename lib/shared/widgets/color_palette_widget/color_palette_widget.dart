import 'package:flutter/material.dart';

class ColorPalette extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onSelect;

  const ColorPalette({super.key, required this.selectedColor, required this.onSelect});

  static const int columns = 11;

  static final List<Color> _colors = [
    ...List.generate(columns, (i) => Color.lerp(Colors.white, Colors.black, i / (columns - 1))!),
    ...List.generate(10 * columns, (i) {
      final hue = (i % columns) * (360 / columns);
      final valueRow = (i ~/ columns) % 10;
      final value = 1 - (valueRow * 0.08);
      return HSVColor.fromAHSV(1, hue, 0.85, value.clamp(0.2, 1.0)).toColor();
    }),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: columns * 22,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
            ),
            itemCount: _colors.length,
            itemBuilder: (_, index) {
              final color = _colors[index];
              final isSelected = color.toARGB32() == selectedColor.toARGB32();
              return GestureDetector(
                onTap: () => onSelect(color),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: isSelected ? Colors.white : Colors.transparent),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
