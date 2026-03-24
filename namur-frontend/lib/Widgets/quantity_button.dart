import 'package:flutter/material.dart';

class QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const QuantityButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.green),
      onPressed: onPressed,
    );
  }
}
