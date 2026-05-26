import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/inventario_api.dart';

void mostrarModalSalidaStock(BuildContext context, String productoId, String productoNombre, int stockActual, {VoidCallback? onSuccess}) {
  final cantidadController = TextEditingController();
  final observacionesController = TextEditingController();
  bool cargando = false;

  final api = InventarioApi();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Salida de Stock - $productoNombre',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Itim'),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _modalTextField(
                      'Cantidad',
                      cantidadController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.remove_circle_outline,
                      hintText: 'Stock actual: $stockActual',
                    ),
                    const SizedBox(height: 16),
                    _modalTextField('Observaciones (Opcional)', observacionesController, maxLines: 4),
                    const SizedBox(height: 28),
                    _botonGuardar(
                      cargando ? 'Guardando...' : 'Registrar Salida',
                      cargando ? null : () async {
                        final cantidad = int.tryParse(cantidadController.text);
                        if (cantidad == null || cantidad <= 0) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ingrese una cantidad válida')),
                            );
                          }
                          return;
                        }

                        if (cantidad > stockActual) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('La cantidad no puede exceder el stock actual ($stockActual)'), backgroundColor: Colors.red),
                            );
                          }
                          return;
                        }

                        setModalState(() => cargando = true);

                        final resultado = await api.salidaStock(
                          productoId,
                          cantidad,
                          motivo: observacionesController.text.isNotEmpty ? observacionesController.text : null,
                        );

                        setModalState(() => cargando = false);

                        if (resultado['success'] == true) {
                          Navigator.pop(context);
                          onSuccess?.call();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Stock reducido exitosamente'),
                                backgroundColor: Colors.black,
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(resultado['message'] ?? 'Error al reducir stock'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _modalTextField(String label, TextEditingController controller,
    {int maxLines = 1, String? prefix, TextInputType? keyboardType, IconData? prefixIcon, IconData? suffixIcon, String? hintText}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Itim')),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration: InputDecoration(
          prefixText: prefix,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.red) : null,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.red) : null,
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    ],
  );
}

Widget _botonGuardar(String label, VoidCallback? onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE53935),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Itim'),
      ),
    ),
  );
}