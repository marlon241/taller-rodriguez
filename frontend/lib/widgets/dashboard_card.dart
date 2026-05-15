import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';

class DashboardCard extends StatefulWidget {
  final MenuItemModel item;
  final String ruta;

  const DashboardCard({super.key, required this.item, required this.ruta});

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
      child: GestureDetector(
      onTap: () {
          Navigator.pushNamed(context, widget.ruta);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? Colors.black.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.06),
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
            Navigator.pushNamed(context, widget.ruta);  
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                widget.item.imagePath,
                width: _hovered ? 100 : 80,
                height: _hovered ? 100 : 80,
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
                  fontSize: 25,
                  fontFamily: 'Itim',
                  color: Color.fromARGB(255, 0, 0, 0), 
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}