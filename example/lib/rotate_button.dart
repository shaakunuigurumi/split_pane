import 'package:flutter/material.dart';

class RotateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RotateButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      icon: Icon(Icons.rotate_left),
      tooltip: 'Rotate',
      onPressed: onPressed,
    );
  }
}
