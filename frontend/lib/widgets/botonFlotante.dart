
import 'package:flutter/material.dart';

class GenericFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const GenericFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.backgroundColor,
    this.iconColor,
    this.size = 56,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? const Color(0xFFE53935),
      tooltip: tooltip,
      elevation: 6,
      shape: const CircleBorder(),
      child: Icon(
        icon,
        color: iconColor ?? Colors.white,
        size: 28,
      ),
    );
  }
}