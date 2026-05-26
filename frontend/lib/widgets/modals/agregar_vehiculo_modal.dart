import 'package:flutter/material.dart';

class AgregarVehiculoModal extends StatefulWidget {
  const AgregarVehiculoModal({super.key});

  @override
  State<AgregarVehiculoModal> createState() => _AgregarVehiculoModalState();
}

class _AgregarVehiculoModalState extends State<AgregarVehiculoModal> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _modeloCtrl = TextEditingController();
  final TextEditingController _marcaCtrl = TextEditingController();
  final TextEditingController _placaCtrl = TextEditingController();
  final TextEditingController _anioCtrl = TextEditingController();
  final TextEditingController _fechaIngresoCtrl = TextEditingController();
  final TextEditingController _fechaSalidaCtrl = TextEditingController();
  final TextEditingController _diagnosticoCtrl = TextEditingController();

  String? _cliente;
  String? _empleadoAsignado;
  String? _estado;

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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 850;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isWide ? 920 : double.infinity,
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Agregar Vehículo",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Itim'),
                  ),
                ),
                const SizedBox(height: 28),

                // Fila 1
                isWide
                    ? Row(
                        children: [
                          Expanded(child: _buildTextField("Modelo del vehículo", _modeloCtrl)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField("Marca del vehículo", _marcaCtrl)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField("Placa del vehículo", _placaCtrl)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildTextField("Modelo del vehículo", _modeloCtrl),
                          const SizedBox(height: 14),
                          _buildTextField("Marca del vehículo", _marcaCtrl),
                          const SizedBox(height: 14),
                          _buildTextField("Placa del vehículo", _placaCtrl),
                        ],
                      ),
                const SizedBox(height: 16),

                // Fila 2: Cliente, Empleado, Estado
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDropdown("Cliente", _cliente, ["Juan Pérez", "María Gómez", "Jared Amaya"], (val) => setState(() => _cliente = val)),
                                const SizedBox(height: 8),
                                OutlinedButton(onPressed: () {}, child: const Text("Agregar cliente nuevo")),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDropdown("Empleado asignado", _empleadoAsignado, ["Carlos López", "Ana Martínez", "Pedro Ramírez"], (val) => setState(() => _empleadoAsignado = val)),
                                const SizedBox(height: 8),
                                OutlinedButton(onPressed: () {}, child: const Text("Agregar empleado nuevo")),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown("Estado", _estado, ["En revisión", "Reparando", "Listo"], (val) => setState(() => _estado = val)),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildDropdown("Cliente", _cliente, ["Juan Pérez", "María Gómez", "Jared Amaya"], (val) => setState(() => _cliente = val)),
                          const SizedBox(height: 14),
                          _buildDropdown("Empleado asignado", _empleadoAsignado, ["Carlos López", "Ana Martínez", "Pedro Ramírez"], (val) => setState(() => _empleadoAsignado = val)),
                          const SizedBox(height: 14),
                          _buildDropdown("Estado", _estado, ["En revisión", "Reparando", "Listo"], (val) => setState(() => _estado = val)),
                        ],
                      ),

                const SizedBox(height: 16),

                // Fila 3
                isWide
                    ? Row(
                        children: [
                          Expanded(child: _buildTextField("Año del vehículo", _anioCtrl, keyboardType: TextInputType.number)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildFechaField("Fecha de ingreso", _fechaIngresoCtrl)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildFechaField("Fecha de salida", _fechaSalidaCtrl)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildTextField("Año del vehículo", _anioCtrl, keyboardType: TextInputType.number),
                          const SizedBox(height: 14),
                          _buildFechaField("Fecha de ingreso", _fechaIngresoCtrl),
                          const SizedBox(height: 14),
                          _buildFechaField("Fecha de salida", _fechaSalidaCtrl),
                        ],
                      ),

                const SizedBox(height: 24),

                // Diagnóstico + Imágenes
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildDiagnostico()),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const SizedBox(height: 28),
                                _botonImagen("Agregar imagen - Vehículo"),
                                const SizedBox(height: 12),
                                _botonImagen("Agregar imagen - Tarjeta de circulación"),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDiagnostico(),
                          const SizedBox(height: 12),
                          _botonImagen("Agregar imagen - Vehículo"),
                          const SizedBox(height: 12),
                          _botonImagen("Agregar imagen - Tarjeta de circulación"),
                        ],
                      ),

                const SizedBox(height: 32),

                Center(
                  child: SizedBox(
                    width: 320,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _agregarVehiculo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC0392B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Agregar vehículo",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Itim', color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== DROPDOWN CORREGIDO ====================
  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text("Seleccionar $label"),
          isExpanded: true,                    // ← SOLUCIÓN PRINCIPAL
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

  // Resto de widgets (sin cambios importantes)
  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
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
            hintText: "Escriba el diagnóstico inicial del vehículo...",
          ),
        ),
      ],
    );
  }

  Widget _botonImagen(String label) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add_a_photo, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC0392B),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
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
                controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
              });
            }
          },
        ),
      ],
    );
  }

  void _agregarVehiculo() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vehículo agregado correctamente"), backgroundColor: Color(0xFFC0392B)),
      );
    }
  }
}