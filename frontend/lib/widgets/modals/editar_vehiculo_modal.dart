import 'package:flutter/material.dart';
import '../../services/vehiculo_service.dart';

class EditarVehiculoModal extends StatefulWidget {
  final Map<String, dynamic> vehiculo;
  final VoidCallback onVehiculoEditado;

  const EditarVehiculoModal({
    super.key,
    required this.vehiculo,
    required this.onVehiculoEditado,
  });

  @override
  State<EditarVehiculoModal> createState() => _EditarVehiculoModalState();
}

class _EditarVehiculoModalState extends State<EditarVehiculoModal> {
  late TextEditingController _modeloCtrl;
  late TextEditingController _marcaCtrl;
  late TextEditingController _placaCtrl;
  late TextEditingController _anioCtrl;
  late TextEditingController _fechaIngresoCtrl;
  late TextEditingController _fechaSalidaCtrl;
  late TextEditingController _diagnosticoCtrl;
  String? _estado;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final v = widget.vehiculo;
    _modeloCtrl = TextEditingController(text: v['modelo'] ?? '');
    _marcaCtrl = TextEditingController(text: v['marca'] ?? '');
    _placaCtrl = TextEditingController(text: v['placa'] ?? '');
    _anioCtrl = TextEditingController(text: '${v['anio'] ?? ''}');
    _diagnosticoCtrl = TextEditingController(text: v['diagnostico'] ?? '');
    _estado = v['estado'];

    // Formatear fechas para mostrar en el campo
    _fechaIngresoCtrl = TextEditingController(
      text: _fechaParaCampo(v['fecha_ingreso']),
    );
    _fechaSalidaCtrl = TextEditingController(
      text: _fechaParaCampo(v['fecha_salida']),
    );
  }

  @override
  void dispose() {
    _modeloCtrl.dispose();
    _marcaCtrl.dispose();
    _placaCtrl.dispose();
    _anioCtrl.dispose();
    _fechaIngresoCtrl.dispose();
    _fechaSalidaCtrl.dispose();
    _diagnosticoCtrl.dispose();
    super.dispose();
  }

  String _fechaParaCampo(dynamic fecha) {
    if (fecha == null) return '';
    final dt = DateTime.tryParse(fecha.toString());
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _parseFecha(String fecha) {
    final partes = fecha.split('/');
    if (partes.length == 3) {
      return '${partes[2]}-${partes[1].padLeft(2, '0')}-${partes[0].padLeft(2, '0')}T00:00:00';
    }
    return DateTime.now().toIso8601String();
  }

  Future<void> _guardarCambios() async {
    if (_modeloCtrl.text.isEmpty || _marcaCtrl.text.isEmpty ||
        _placaCtrl.text.isEmpty || _anioCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa los campos requeridos: modelo, marca, placa y año'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    final datos = {
      'modelo': _modeloCtrl.text,
      'marca': _marcaCtrl.text,
      'placa': _placaCtrl.text,
      'anio': int.tryParse(_anioCtrl.text) ?? 0,
      'diagnostico': _diagnosticoCtrl.text,
      'estado': _estado ?? widget.vehiculo['estado'],
      'fecha_ingreso': _fechaIngresoCtrl.text.isNotEmpty
          ? _parseFecha(_fechaIngresoCtrl.text)
          : null,
      'fecha_salida': _fechaSalidaCtrl.text.isNotEmpty
          ? _parseFecha(_fechaSalidaCtrl.text)
          : null,
    };

    final result = await VehiculoService.actualizarVehiculo(
      widget.vehiculo['id'],
      datos,
    );

    setState(() => _guardando = false);

    if (result['success'] == true) {
      widget.onVehiculoEditado();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehículo actualizado correctamente'),
          backgroundColor: Color(0xFFC0392B),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error al actualizar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 850;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isWide ? 920 : double.infinity,
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Editar Vehículo",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Itim'),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Fila 1: Modelo, Marca, Placa
              isWide
                  ? Row(children: [
                      Expanded(child: _buildTextField("Modelo del vehículo", _modeloCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("Marca del vehículo", _marcaCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("Placa del vehículo", _placaCtrl)),
                    ])
                  : Column(children: [
                      _buildTextField("Modelo del vehículo", _modeloCtrl),
                      const SizedBox(height: 14),
                      _buildTextField("Marca del vehículo", _marcaCtrl),
                      const SizedBox(height: 14),
                      _buildTextField("Placa del vehículo", _placaCtrl),
                    ]),
              const SizedBox(height: 16),

              // Fila 2: Año, Estado, Fechas
              isWide
                  ? Row(children: [
                      Expanded(child: _buildTextField("Año", _anioCtrl, keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDropdown("Estado", _estado,
                          ["En revisión", "Reparando", "Listo", "Entregado"],
                          (val) => setState(() => _estado = val))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildFechaField("Fecha de ingreso", _fechaIngresoCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildFechaField("Fecha de salida", _fechaSalidaCtrl)),
                    ])
                  : Column(children: [
                      _buildTextField("Año", _anioCtrl, keyboardType: TextInputType.number),
                      const SizedBox(height: 14),
                      _buildDropdown("Estado", _estado,
                          ["En revisión", "Reparando", "Listo", "Entregado"],
                          (val) => setState(() => _estado = val)),
                      const SizedBox(height: 14),
                      _buildFechaField("Fecha de ingreso", _fechaIngresoCtrl),
                      const SizedBox(height: 14),
                      _buildFechaField("Fecha de salida", _fechaSalidaCtrl),
                    ]),
              const SizedBox(height: 16),

              // Diagnóstico
              _buildDiagnostico(),
              const SizedBox(height: 32),

              // Botón guardar
              Center(
                child: SizedBox(
                  width: 320,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardarCambios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC0392B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "Guardar cambios",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Itim', color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text("Seleccionar $label"),
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDiagnostico() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Diagnóstico", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _diagnosticoCtrl,
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: "Diagnóstico del vehículo...",
          ),
        ),
      ],
    );
  }

  Widget _buildFechaField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              setState(() {
                controller.text =
                    "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
              });
            }
          },
        ),
      ],
    );
  }
}