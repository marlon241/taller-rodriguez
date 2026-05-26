import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/empleado_back.dart';
import 'package:frontend/services/empleado_service.dart';

class AgregarEmpleadoModal extends StatefulWidget {
  final Empleado? empleado;

  const AgregarEmpleadoModal({super.key, this.empleado});

  @override
  State<AgregarEmpleadoModal> createState() => _AgregarEmpleadoModalState();
}

class _AgregarEmpleadoModalState extends State<AgregarEmpleadoModal> {
  final _formKey = GlobalKey<FormState>();
  bool tieneLicencia = true;
  bool _guardando = false;

  final TextEditingController _nombreCtrl    = TextEditingController();
  final TextEditingController _duiCtrl       = TextEditingController();
  final TextEditingController _telefonoCtrl  = TextEditingController();
  final TextEditingController _sueldoCtrl    = TextEditingController();
  final TextEditingController _porcentajeCtrl = TextEditingController();
  final TextEditingController _fechaCtrl     = TextEditingController();
  final TextEditingController _contrasenaCtrl = TextEditingController();

  String? _cargo;

  bool get _esEdicion => widget.empleado != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final e = widget.empleado!;
      _nombreCtrl.text     = e.nombre;
      _duiCtrl.text        = e.dui;
      _telefonoCtrl.text   = e.telefono;
      _sueldoCtrl.text     = e.sueldoBase.toString();
      _porcentajeCtrl.text = e.porcentajeGanancia?.toString() ?? '';
      _contrasenaCtrl.text = e.contrasena;
      tieneLicencia        = e.licencia;
      _cargo               = e.cargo.isNotEmpty ? e.cargo : null;

      if (e.fechaContratacion.isNotEmpty) {
        final partes = e.fechaContratacion.split('-');
        if (partes.length == 3) {
          _fechaCtrl.text = '${partes[2]}/${partes[1]}/${partes[0]}';
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _duiCtrl.dispose();
    _telefonoCtrl.dispose();
    _sueldoCtrl.dispose();
    _porcentajeCtrl.dispose();
    _fechaCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  // ── Validadores ──────────────────────────────────────────────────────────

  String? _validarRequerido(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null;

  String? _validarDui(String? v) {
    if (v == null || v.trim().isEmpty) return 'Este campo es obligatorio';
    if (!RegExp(r'^\d{8}-\d$').hasMatch(v.trim())) {
      return 'Formato inválido. Ejemplo: 01234567-8';
    }
    return null;
  }

  String? _validarTelefono(String? v) {
    if (v == null || v.trim().isEmpty) return 'Este campo es obligatorio';
    if (!RegExp(r'^\d{8}$').hasMatch(v.trim())) {
      return 'Debe tener exactamente 8 dígitos';
    }
    return null;
  }

  String? _validarSueldo(String? v) {
    if (v == null || v.trim().isEmpty) return 'Este campo es obligatorio';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Ingresa un número válido';
    if (n <= 0) return 'El sueldo debe ser mayor a \$0';
    return null;
  }

  String? _validarPorcentaje(String? v) {
    if (v == null || v.trim().isEmpty) return null; // opcional
    final n = double.tryParse(v.trim());
    if (n == null) return 'Ingresa un número válido';
    if (n < 0 || n > 100) return 'Debe estar entre 0 y 100';
    return null;
  }

  String? _validarContrasena(String? v) {
    if (v == null || v.trim().isEmpty) return 'Este campo es obligatorio';
    if (v.trim().length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Debe tener al menos una mayúscula';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Debe tener al menos un número';
    return null;
   }
  // ── Guardado ─────────────────────────────────────────────────────────────

  Future<void> _guardarEmpleado() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final partes   = _fechaCtrl.text.split('/');
      final fechaIso = '${partes[2]}-${partes[1]}-${partes[0]}';

      final empleado = Empleado(
        id:                 widget.empleado?.id,
        nombre:             _nombreCtrl.text.trim(),
        dui:                _duiCtrl.text.trim(),
        telefono:           _telefonoCtrl.text.trim(),
        cargo:              _cargo!,
        contrasena:         _contrasenaCtrl.text.trim(),
        estado:             widget.empleado?.estado ?? true,
        sueldoBase:         double.parse(_sueldoCtrl.text.trim()),
        fechaContratacion:  fechaIso,
        licencia:           tieneLicencia,
        porcentajeGanancia: _porcentajeCtrl.text.trim().isNotEmpty
            ? double.tryParse(_porcentajeCtrl.text.trim())
            : null,
      );

      if (_esEdicion) {
        await EmpleadoService.update(empleado);
      } else {
        await EmpleadoService.create(empleado);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  // ── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isWide ? 620 : double.infinity,
        constraints: const BoxConstraints(maxHeight: 680),
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _esEdicion ? 'Editar empleado' : 'Agregar empleado',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Itim',
                  ),
                ),
                const SizedBox(height: 24),

                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _field(isWide, _buildTextField('Nombre', _nombreCtrl)),
                    _field(isWide, _buildTextField('DUI', _duiCtrl,
                        hint: '00000000-0',
                        validator: _validarDui)),
                    _field(isWide, _buildTextField('Número de teléfono', _telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: _validarTelefono)),
                    _field(isWide, _buildTextField('Contraseña', _contrasenaCtrl,
                          obscureText: true,
                           validator: _validarContrasena)),
                    _field(isWide, _buildTextField('Sueldo base', _sueldoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixText: '\$ ',
                        validator: _validarSueldo)),
                    _field(isWide, _buildPorcentajeField()),
                    _field(isWide, _buildCargoField()),
                    _field(isWide, _buildFechaField()),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: tieneLicencia,
                      onChanged: _guardando
                          ? null
                          : (val) => setState(() => tieneLicencia = val!),
                      activeColor: const Color(0xFFC0392B),
                    ),
                    const Text('El empleado tiene licencia',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardarEmpleado,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC0392B),
                      disabledBackgroundColor:
                          const Color(0xFFC0392B).withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _guardando
                        ? const SizedBox(
                            height: 24, width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text(
                            _esEdicion ? 'Guardar cambios' : 'Agregar empleado',
                            style: const TextStyle(
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

  // ── Helpers de layout ────────────────────────────────────────────────────

  Widget _field(bool isWide, Widget child) =>
      SizedBox(width: isWide ? 270 : double.infinity, child: child);

  // ── Campos ───────────────────────────────────────────────────────────────

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? hint,
    String? prefixText,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: !_guardando,
          inputFormatters: inputFormatters,
          validator: validator ?? _validarRequerido,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        const Text('Porcentaje de ganancia',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _porcentajeCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: !_guardando,
          validator: _validarPorcentaje,
          decoration: InputDecoration(
            hintText: 'Opcional',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixText: '%',
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildCargoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cargo', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _cargo,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorMaxLines: 2,
          ),
          hint: const Text('Seleccionar...'),
          validator: (v) => v == null ? 'Este campo es obligatorio' : null,
          items: const [
            DropdownMenuItem(value: 'Administrador', child: Text('Administrador')),
            DropdownMenuItem(value: 'Mecanico',      child: Text('Mecánico')),
            DropdownMenuItem(value: 'Secretaria',    child: Text('Secretaria')),
          ],
          onChanged: _guardando
              ? null
              : (v) => setState(() => _cargo = v),
        ),
      ],
    );
  }

  Widget _buildFechaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fecha de contratación',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _fechaCtrl,
          enabled: !_guardando,
          readOnly: true,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Este campo es obligatorio' : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: const Icon(Icons.calendar_today),
            errorMaxLines: 2,
          ),
          onTap: _guardando
              ? null
              : () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _fechaCtrl.text =
                          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                    });
                  }
                },
        ),
      ],
    );
  }
}