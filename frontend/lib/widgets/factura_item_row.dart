import 'package:flutter/material.dart';

class FacturaItemRow extends StatelessWidget {
  final int cantidad;
  final String nombre;
  final String tipo;
  final double precio;

  const FacturaItemRow({
    super.key,
    required this.cantidad,
    required this.nombre,
    required this.tipo,
    required this.precio,
  });

  @override
  Widget build(BuildContext context) {
    final bool isServicio = tipo.toLowerCase() == "servicio";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              cantidad.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              nombre,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isServicio ? Colors.orange.shade100 : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tipo,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: isServicio ? Colors.orange.shade800 : Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '\$${precio.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          SizedBox(
            width: 32,
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