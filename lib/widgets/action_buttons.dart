import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final String mode;

  const ActionButtons({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final buttons = mode == "live"
        ? ["Record", "Talk", "PTZ", "Screenshot", "Quality", "Voice"]
        : ["Data", "Record", "Screenshot", "Voice", "Download"];

    return GridView.builder(
      itemCount: buttons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return ElevatedButton(
          onPressed: () {},
          child: Text(buttons[index]),
        );
      },
    );
  }
}
