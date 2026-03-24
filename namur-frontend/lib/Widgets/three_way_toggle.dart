import 'package:flutter/material.dart';

class ThreeWayToggle extends StatelessWidget {
  final String selectedValue; // 'rent', 'all', 'sell'
  final ValueChanged<String> onChanged;

  const ThreeWayToggle({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFD0D0D0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment('rent', 'Rent'),
          _buildCenterDot('all'),
          _buildSegment('sell', 'Buy'),
        ],
      ),
    );
  }

  Widget _buildSegment(String value, String label) {
    final isSelected = selectedValue.toLowerCase() == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterDot(String value) {
    final isSelected = selectedValue.toLowerCase() == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.shade500,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
