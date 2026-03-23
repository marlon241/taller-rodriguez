import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';

class DashboardCard extends StatefulWidget {
  final MenuItemModel item;

  const DashboardCard({super.key, required this.item});

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? Colors.black.withOpacity(0.15)
                  : Colors.black.withOpacity(0.06),
              blurRadius: _hovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        transform: _hovered
            ? (Matrix4.identity()..scale(1.04))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
           
            debugPrint('Tapped: ${widget.item.label}');
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                widget.item.imagePath,
                width: 56,
                height: 56,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 56,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.item.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}