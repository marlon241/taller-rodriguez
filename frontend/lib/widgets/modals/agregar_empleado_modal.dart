import 'package:flutter/material.dart';
import 'package:frontend/widgets/modals/exito_modal.dart';

class AgregarEmpleadoModal extends StatefulWidget {
  const AgregarEmpleadoModal({super.key});

  @override
  State<AgregarEmpleadoModal> createState() => _AgregarEmpleadoModalState();
}

class _AgregarEmpleadoModalState extends State<AgregarEmpleadoModal> {
  final _formKey = GlobalKey<FormState>();
  bool tieneLicencia = true;

  // Controladores
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _duiCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _sueldoCtrl = TextEditingController();
  final TextEditingController _porcentajeCtrl = TextEditingController();
  final TextEditingController _fechaCtrl = TextEditingController();

  String? _tipoEmpleado;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _duiCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _sueldoCtrl.dispose();
    _porcentajeCtrl.dispose();
    _fechaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isWide ? 620 : double.infinity,
        constraints: const BoxConstraints(maxHeight: 680), // ← Evita overflow
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Agregar empleado",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Itim',
                  ),
                ),
                const SizedBox(height: 24),

                // Usamos Column + Wrap en vez de GridView para mayor flexibilidad
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                        width: isWide ? 270 : double.infinity,
                        child: _buildTextField("Nombre", _nombreCtrl)),
                    SizedBox(
                        width: isWide ? 270 : double.infinity,
                        child: _buildTextField("DUI", _duiCtrl)),
                    SizedBox(
                        width: isWide ? 270 : double.infinity,
                        child: _buildTextField("Correo electrónico", _emailCtrl,
                            keyboardType: TextInputType.emailAddress)),
                    SizedBox(
                        width: isWide ? 270 : double.infinity,
                        child: _buildTextField("Número de teléfono", _telefonoCtrl,
                            keyboardType: TextInputType.phone)),
                    SizedBox(
                        width: isWide ? 270 : double.infinity,
                        child: _buildTextField("Sueldo base", _sueldoCtrl,
                            keyboardType: TextInputType.number)),
                    SizedBox(
                        width: isWide ? 270 : double.infinity,
                        child: _buildPorcentajeField()),
                    SizedBox(
                        width: isWide ? 270 : double.infinity,
                        child: _buildTipoEmpleadoField()),
                    SizedBox(
                        width: isWide ? 270 : double.infinity,
                        child: _buildFechaField()),
                  ],
                ),

                const SizedBox(height: 12),

                // Licencia
                Row(
                  children: [
                    Checkbox(
                      value: tieneLicencia,
                      onChanged: (val) => setState(() => tieneLicencia = val!),
                      activeColor: const Color(0xFFC0392B),
                    ),
                    const Text(
                      "El empleado tiene licencia",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Botón Agregar
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _agregarEmpleado,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC0392B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Agregar empleado",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Itim',
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

  void _agregarEmpleado() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ExitoModal(),
      );
      _limpiarCampos();
    }
  }

  void _limpiarCampos() {
    _nombreCtrl.clear();
    _duiCtrl.clear();
    _emailCtrl.clear();
    _telefonoCtrl.clear();
    _sueldoCtrl.clear();
    _porcentajeCtrl.clear();
    _fechaCtrl.clear();
    _tipoEmpleado = null;
    tieneLicencia = true;
  }

  // ==================== CAMPOS ====================

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
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? "Este campo es obligatorio" : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildPorcentajeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Porcentaje de ganancia", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _porcentajeCtrl,
          keyboardType: TextInputType.number,
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? "Este campo es obligatorio" : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixText: "%",
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildTipoEmpleadoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tipo de empleado", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _tipoEmpleado,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorMaxLines: 2,
          ),
          hint: const Text("Seleccionar..."),
          validator: (value) => value == null ? "Este campo es obligatorio" : null,
          items: const [
            DropdownMenuItem(value: "Cocinero", child: Text("Cocinero")),
            DropdownMenuItem(value: "Mesero", child: Text("Mesero")),
            DropdownMenuItem(value: "Repartidor", child: Text("Repartidor")),
            DropdownMenuItem(value: "Admin", child: Text("Administrativo")),
          ],
          onChanged: (value) => setState(() => _tipoEmpleado = value),
        ),
      ],
    );
  }

  Widget _buildFechaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Fecha de contratación", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _fechaCtrl,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: const Icon(Icons.calendar_today),
            errorMaxLines: 2,
          ),
          readOnly: true,
          validator: (value) => value!.isEmpty ? "Este campo es obligatorio" : null,
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _fechaCtrl.text =
                    "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
              });
            }
          },
        ),
      ],
    );
  }
}