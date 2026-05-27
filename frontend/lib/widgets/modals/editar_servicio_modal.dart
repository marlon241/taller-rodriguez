import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/inventario_api.dart';
import 'package:frontend/services/proveedor_api.dart';
import 'package:frontend/utils/validadores.dart';

void mostrarModalEditarServicio(BuildContext context, Map<String, dynamic> producto, {VoidCallback? onSuccess}) {
  final nombreController = TextEditingController(text: producto['nombre']?.toString() ?? '');
  final precioCompraController = TextEditingController(text: producto['precio_compra']?.toString() ?? '');
  final precioVentaController = TextEditingController(text: producto['precio_venta']?.toString() ?? '');
  final descripcionController = TextEditingController(text: producto['descripcion']?.toString() ?? '');
  String? clasificacion = producto['clasificacion']?.toString();
  bool cargando = false;
  List<Map<String, dynamic>> proveedores = [];
  String? idProveedorSeleccionado = producto['id_proveedor']?.toString();

  final api = InventarioApi();
  final proveedorApi = ProveedorApi();
  final String id = producto['id']?.toString() ?? '';

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          if (proveedores.isEmpty) {
            proveedorApi.obtenerProveedores().then((data) {
              setModalState(() {
                proveedores = data;
              });
            });
          }

          String? nombreProveedorSeleccionado;
          if (idProveedorSeleccionado != null && idProveedorSeleccionado!.isNotEmpty) {
            final prov = proveedores.firstWhere(
              (p) => p['id']?.toString() == idProveedorSeleccionado,
              orElse: () => {},
            );
            nombreProveedorSeleccionado = prov['nombre']?.toString();
          } else {
            nombreProveedorSeleccionado = 'Sin proveedor';
          }

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
                        'Editar servicio',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Itim'),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(child: _modalTextField('Nombre del servicio:', nombreController)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _modalDropdownProveedor(
                            'Proveedor',
                            nombreProveedorSeleccionado,
                            proveedores,
                            (val) {
                              if (val != null && val != 'Sin proveedor') {
                                final prov = proveedores.firstWhere((p) => p['nombre'] == val, orElse: () => {});
                                setModalState(() {
                                  idProveedorSeleccionado = prov['id']?.toString();
                                });
                              } else {
                                setModalState(() {
                                  idProveedorSeleccionado = null;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _modalTextField('Precio de compra:', precioCompraController, prefix: '\$', keyboardType: TextInputType.number, formatters: [ValidadorPrecio()])),
                        const SizedBox(width: 16),
                        Expanded(child: _modalTextField('Precio de venta:', precioVentaController, prefix: '\$', keyboardType: TextInputType.number, formatters: [ValidadorPrecio()])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _modalDropdown('Clasificación de servicio:', clasificacion,
                      ['Aceites y fluidos', 'Frenos', 'Motor', 'Eléctrico', 'Suspensión', 'Transmisión', 'Carrocería', 'Accesorios'],
                      (val) => setModalState(() => clasificacion = val)),
                    const SizedBox(height: 16),
                    _modalTextField('Descripción (Opcional):', descripcionController, maxLines: 4),
                    const SizedBox(height: 28),
                    _botonGuardar(
                      cargando ? 'Guardando...' : 'Guardar cambios',
                      cargando ? null : () async {
                        if (nombreController.text.isEmpty || id.isEmpty) {
                          return;
                        }

                        setModalState(() => cargando = true);

                        final resultado = await api.actualizarProducto(id, {
                          'nombre': nombreController.text,
                          'tipo': 'Servicio',
                          'clasificacion': clasificacion,
                          'descripcion': descripcionController.text,
                          'precio_compra': double.tryParse(precioCompraController.text) ?? 0,
                          'precio_venta': double.tryParse(precioVentaController.text) ?? 0,
                          'id_proveedor': idProveedorSeleccionado,
                        });

                        setModalState(() => cargando = false);

                        if (resultado['success'] == true) {
                          Navigator.pop(context);
                          onSuccess?.call();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Servicio actualizado exitosamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(resultado['message'] ?? 'Error al actualizar'), backgroundColor: Colors.red),
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
    {int maxLines = 1, String? prefix, TextInputType? keyboardType, Function(String)? onChanged, List<TextInputFormatter>? formatters}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Itim')),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: formatters ?? [],
        onChanged: onChanged,
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

Widget _modalDropdownProveedor(String label, String? value, List<Map<String, dynamic>> proveedores, ValueChanged<String?> onChanged) {
  final nombres = ['Sin proveedor', ...proveedores.map((p) => p['nombre']?.toString() ?? '').toList()];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Itim')),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value != null && nombres.contains(value) ? value : null,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: nombres.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
        onChanged: onChanged,
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
