import 'package:flutter/material.dart';

void mostrarModalSalidaStock(BuildContext context) {
  String? producto;
  String? tipoSalida;
  final cantidadController = TextEditingController();
  final clienteController = TextEditingController();
  final observacionesController = TextEditingController();

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
                        'Salida de Stock',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Itim'),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _modalDropdown('Producto', producto,
                            ['Bujia 10W-40', 'Aceite de caja', 'Refrigerante'],
                            (val) => setModalState(() => producto = val)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _modalTextField('Cantidad', cantidadController, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _modalDropdown('Tipo de salida', tipoSalida,
                            ['Venta a cliente', 'Uso interno', 'Merma', 'Otro'],
                            (val) => setModalState(() => tipoSalida = val)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _modalTextField('Cliente', clienteController)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _modalTextField('Observaciones', observacionesController, maxLines: 4),
                    const SizedBox(height: 28),
                    _botonGuardar('Registrar Salida', () => Navigator.pop(context)),
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