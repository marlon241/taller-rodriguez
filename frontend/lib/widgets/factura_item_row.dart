
import 'package:flutter/material.dart';

class FacturaItemRow extends StatelessWidget {
  final int id;
  final int cantidad;
  final String nombre;
  final String tipo;
  final double precio;

  const FacturaItemRow({
    super.key,
    required this.id,
    required this.cantidad,
    required this.nombre,
    required this.tipo,
    required this.precio,
  });

  @override
  Widget build(BuildContext context) {
    final bool isServicio = tipo == "Servicio";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
         
          Expanded(
            flex: 1,
            child: Text(
              "#$id",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          
          Expanded(
            flex: 2,
            child: Text(
              "$cantidad",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
         
          Expanded(
            flex: 4,
            child: Text(nombre, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis, maxLines: 1),
          ),
         
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isServicio ? Colors.orange.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tipo,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isServicio ? Colors.orange.shade700 : Colors.blue.shade700,
                  ),
                ),
              ),
            ),
          ),
         
          Expanded(
            flex: 2,
            child: Text(
              "\$${precio.toStringAsFixed(2)}",
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}