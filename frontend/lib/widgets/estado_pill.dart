import 'package:flutter/material.dart';

class EstadoPill extends StatelessWidget {
  final String nombre;
  final Color color;
  final VoidCallback? onPressed;
  final Color? colorTexto;
  final double minAncho;

  const EstadoPill({
    super.key,
    required this.nombre,
    required this.color,
    this.onPressed,
    this.colorTexto,
    this.minAncho = 130,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,

      child: Container(
        width: minAncho,
        height: 45,

        alignment: Alignment.center,

        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Text(
          nombre,
          textAlign: TextAlign.center,

          style: TextStyle(
            color: colorTexto ??
                (color.computeLuminance() > 0.5
                    ? Colors.black87
                    : Colors.white),

            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}