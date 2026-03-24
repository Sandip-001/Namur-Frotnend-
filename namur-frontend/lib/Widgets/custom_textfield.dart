import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType inputType;
  final bool isMandatory;
  final double? widthFactor;
  final Color? fillColor;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final int maxLines;
  final int? maxLength; // 🔹 NEW OPTIONAL MAX LENGTH

  const CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.inputType = TextInputType.text,
    this.isMandatory = false,
    this.widthFactor,
    this.fillColor,
    this.onChanged,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength, // 🔹 OPTIONAL
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * (widthFactor ?? 0.85);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: width,
        child: TextField(
          controller: controller,
          keyboardType: inputType,
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength, // 🔹 Apply max length
          onChanged: onChanged,
          decoration: InputDecoration(
            counterText: "", // 🔹 Hide counter unless maxLength given
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor:
                fillColor ??
                (isMandatory
                    ? const Color.fromRGBO(255, 204, 204, 0.8)
                    : const Color.fromRGBO(232, 229, 229, 0.75)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isMandatory ? Colors.red : Colors.grey.shade300,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isMandatory ? Colors.red : Colors.green,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
