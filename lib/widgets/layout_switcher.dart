import 'package:flutter/material.dart';

class LayoutSwitcher extends StatelessWidget {
  final int currentLayout;
  final ValueChanged<int> onLayoutChange;

  const LayoutSwitcher({
    super.key,
    required this.currentLayout,
    required this.onLayoutChange,
  });

  @override
  Widget build(BuildContext context) {
    final layouts = [1, 2, 3, 4]; // Layout options

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: layouts.map((layout) {
        final isSelected = layout == currentLayout;
        return GestureDetector(
          onTap: () => onLayoutChange(layout),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurple : Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              "$layout x $layout",
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
