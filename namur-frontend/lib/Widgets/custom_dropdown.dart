import 'package:flutter/material.dart';
import '../utils/string_extension.dart';

class CustomDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final Color? fillColor;
  final double? widthFactor;
  final double horizontalPadding;
  final double verticalPadding;

  const CustomDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.fillColor,
    this.widthFactor,
    this.horizontalPadding = 20.0,
    this.verticalPadding = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure current value exists in list (Case-insensitive check)
    String? matchedValue;
    if (value != null) {
      try {
        matchedValue = items.firstWhere(
          (item) => item.trim().toLowerCase() == value!.trim().toLowerCase(),
        );
      } catch (_) {
        matchedValue = null;
      }
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final targetWidth = screenWidth * (widthFactor ?? 0.85);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 50, // Standard height but can grow
            minWidth: widthFactor != null ? targetWidth : 0,
            maxWidth: widthFactor != null ? targetWidth : double.infinity,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              color: fillColor ?? const Color.fromRGBO(232, 229, 229, 0.75),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                // 🔥 Allow the dropdown to be flexible based on content height
                itemHeight: null, 
                hint: Text(
                  hint,
                  style: const TextStyle(color: Colors.grey),
                ),
                value: matchedValue,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                items: items.map((String val) {
                  return DropdownMenuItem(
                    value: val,
                    // 🔥 Add vertical padding inside the item to prevent clipping
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        val.toTitleCase(),
                        style: const TextStyle(height: 1.2),
                        softWrap: true,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
