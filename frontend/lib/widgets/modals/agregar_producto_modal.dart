import 'package:flutter/material.dart';

void mostrarModalAgregarProducto(BuildContext context) {
  final nombreController = TextEditingController();
  final precioCompraController = TextEditingController();
  final precioVentaController = TextEditingController();
  final descripcionController = TextEditingController();
  String? proveedor;
  String? clasificacion;
  String? tipo;

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
                    const Center(
                      child: Text(
                        'Agregar producto',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Itim'),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(child: _modalTextField('Nombre del producto:', nombreController)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _modalDropdown('Proveedor', proveedor,
                            ['Proveedor A', 'Proveedor B', 'Proveedor C'],
                            (val) => setModalState(() => proveedor = val)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _modalTextField('Precio de compra:', precioCompraController, prefix: '\$')),
                        const SizedBox(width: 16),
                        Expanded(child: _modalTextField('Precio de venta:', precioVentaController, prefix: '\$')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _modalDropdown('Clasificación de producto:', clasificacion,
                            ['Lubricantes', 'Frenos', 'Motor', 'Eléctrico'],
                            (val) => setModalState(() => clasificacion = val)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _modalDropdown('Tipo de producto:', tipo,
                            ['Producto', 'Servicio'],
                            (val) => setModalState(() => tipo = val)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _modalTextField('Descripción (Opcional):', descripcionController, maxLines: 4),
                    const SizedBox(height: 28),
                    _botonGuardar('Agregar producto', () => Navigator.pop(context)),
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
    {int maxLines = 1, String? prefix, TextInputType? keyboardType}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Itim')),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixText: prefix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    ],
  );
}

Widget _modalDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Itim')),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: onChanged,
      ),
    ],
  );
}

Widget _botonGuardar(String label, VoidCallback onPressed) {
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