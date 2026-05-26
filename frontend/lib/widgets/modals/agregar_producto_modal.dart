import 'package:flutter/material.dart';
import 'package:frontend/services/inventario_api.dart';
import 'package:frontend/services/proveedor_api.dart';

void mostrarModalAgregarProducto(BuildContext context, {VoidCallback? onSuccess}) {
  final nombreController = TextEditingController();
  final precioCompraController = TextEditingController();
  final precioVentaController = TextEditingController();
  final descripcionController = TextEditingController();
  String? idProveedor;
  String? nombreProveedor;
  String? clasificacion;
  String? tipo;
  bool cargando = false;

  final inventarioApi = InventarioApi();
  final proveedorApi = ProveedorApi();
  List<Map<String, dynamic>> proveedores = [];

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
                          child: _modalDropdown('Proveedor', nombreProveedor,
                            ['Sin proveedor', ...proveedores.map((p) => p['nombre']?.toString() ?? '')],
                            (val) {
                              if (val == 'Sin proveedor' || val == null) {
                                setModalState(() {
                                  nombreProveedor = val;
                                  idProveedor = null;
                                });
                              } else {
                                final prov = proveedores.firstWhere(
                                  (p) => p['nombre']?.toString() == val,
                                  orElse: () => {},
                                );
                                setModalState(() {
                                  nombreProveedor = val;
                                  idProveedor = prov['id']?.toString();
                                });
                              }
                            }),
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
                            ['Aceites y fluidos', 'Frenos', 'Motor', 'Eléctrico', 'Suspensión', 'Transmisión', 'Carrocería', 'Accesorios'],
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
                    _botonGuardar(
                      cargando ? 'Guardando...' : 'Agregar producto',
                      cargando ? null : () async {
                        if (nombreController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('El nombre es requerido')),
                          );
                          return;
                        }
                        if (precioCompraController.text.isEmpty || precioVentaController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Los precios son requeridos')),
                          );
                          return;
                        }
                        if (clasificacion == null || tipo == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Clasificación y tipo son requeridos')),
                          );
                          return;
                        }

                        setModalState(() => cargando = true);

                        final productoData = {
                          'nombre': nombreController.text,
                          'tipo': tipo,
                          'clasificacion': clasificacion,
                          'descripcion': descripcionController.text,
                          'sku': '',
                          'precio_compra': double.tryParse(precioCompraController.text) ?? 0,
                          'precio_venta': double.tryParse(precioVentaController.text) ?? 0,
                          'stock': 0,
                          'stock_minimo': 0,
                          'stock_maximo': 999,
                        };

                        if (idProveedor != null) {
                          productoData['id_proveedor'] = idProveedor;
                        }

                        final resultado = await inventarioApi.crearProducto(productoData);

                        setModalState(() => cargando = false);

                        if (resultado['success'] == true) {
                          Navigator.pop(context);
                          onSuccess?.call();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Producto agregado exitosamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(resultado['message'] ?? 'Error al agregar producto'), backgroundColor: Colors.red),
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