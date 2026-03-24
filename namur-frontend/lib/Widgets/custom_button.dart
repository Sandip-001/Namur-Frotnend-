import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width; // 👈 NEW

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.width, // 👈 optional
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity, // 👈 fallback
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
