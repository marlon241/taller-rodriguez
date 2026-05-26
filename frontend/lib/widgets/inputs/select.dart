import 'package:flutter/material.dart';

class FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFC0392B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(label, style: const TextStyle(color: Colors.white)),
          dropdownColor: const Color(0xFFC0392B),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          items: options.map((opt) => DropdownMenuItem(
            value: opt,
            child: Text(opt, style: const TextStyle(color: Colors.white)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}