import 'package:flutter/material.dart';
import 'package:frontend/services/inventario_api.dart';

void mostrarModalEliminarProducto(BuildContext context, String id, String nombre, {VoidCallback? onSuccess}) {
  final api = InventarioApi();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar el producto "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final exito = await api.eliminarProducto(id);
              if (exito) {
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                onSuccess?.call();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto eliminado exitosamente')),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al eliminar el producto')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  );
}