import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/pages/clientes.dart'; 
import 'package:frontend/services/cliente_service.dart';
import 'package:frontend/models/cliente.dart';

class AgregarClienteModal extends StatefulWidget {
  final Cliente? cliente;
  const AgregarClienteModal({super.key, this.cliente});

  @override
  State<AgregarClienteModal> createState() => _AgregarClienteModalState();
}

class _AgregarClienteModalState extends State<AgregarClienteModal> {
  final _formKey = GlobalKey<FormState>();
  bool _guardando = false;

  // Controladores
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _duiCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _direccionCtrl = TextEditingController();
  final TextEditingController _nitCtrl = TextEditingController();
  final TextEditingController _nrcCtrl = TextEditingController();

  String? _frecuenciaVisita;
  bool _estado = true;

  bool get _esEdicion => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final c = widget.cliente!;
      _nombreCtrl.text = c.nombre;
      _telefonoCtrl.text = c.telefono;
      _duiCtrl.text = c.dui;
      _correoCtrl.text = c.correo ?? '';
      _direccionCtrl.text = c.direccion ?? '';
      _nitCtrl.text = c.nit ?? '';
      _nrcCtrl.text = c.nrc ?? '';
      _frecuenciaVisita = c.frecuenciaVisita;
      _estado = c.estado;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _duiCtrl.dispose();
    _correoCtrl.dispose();
    _direccionCtrl.dispose();
    _nitCtrl.dispose();
    _nrcCtrl.dispose();
    super.dispose();
  }

  // ==================== VALIDACIONES ====================

  String? _validarRequerido(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null;

String? _validarTelefono(String? v) {
  if (v == null || v.trim().isEmpty) return null; // opcional
  if (!RegExp(r'^\d{8}$').hasMatch(v.trim())) {
    return 'Debe tener exactamente 8 dígitos';
  }
  return null;
}

String? _validarDui(String? v) {
  if (v == null || v.trim().isEmpty) return null; // opcional
  if (!RegExp(r'^\d{8}-\d$').hasMatch(v.trim())) {
    return 'Formato inválido. Ejemplo: 01234567-8';
  }
  return null;
}

String? _validarNrc(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  if (!RegExp(r'^\d{6,8}$|^\d{6,8}-\d$').hasMatch(v.trim())) {
    return 'Formato inválido. Ejemplo: 123456 o 123456-7';
  }
  return null;
}

String? _validarEmail(String? v) {
  if (v == null || v.trim().isEmpty) return null; // opcional
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
    return 'Correo electrónico inválido';
  }
  return null;
}
  Future<void> _guardarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final cliente = Cliente(
        id: widget.cliente?.id,
        nombre: _nombreCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        dui: _duiCtrl.text.trim(),
        correo: _correoCtrl.text.trim(),
        direccion: _direccionCtrl.text.trim(),
        frecuenciaVisita: _frecuenciaVisita ?? 'Regular',
        estado: _estado,
        nit: _nitCtrl.text.trim().isEmpty ? null : _nitCtrl.text.trim(),
        nrc: _nrcCtrl.text.trim().isEmpty ? null : _nrcCtrl.text.trim(),
        fechaRegistro: widget.cliente?.fechaRegistro ?? DateTime.now().toIso8601String(),
      );

      if (_esEdicion) {
        await ClienteService.update(cliente);
      } else {
        await ClienteService.create(cliente);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isWide ? 780 : double.infinity,
        constraints: const BoxConstraints(maxHeight: 720),
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _esEdicion ? 'Editar Cliente' : 'Agregar Cliente',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Itim'),
                ),
                const SizedBox(height: 24),

                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _field(isWide, _buildTextField('Nombre', _nombreCtrl)),
                    _field(isWide, _buildTextField('Teléfono', _telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: _validarTelefono)),
                    _field(isWide, _buildTextField('DUI', _duiCtrl,
                        hint: '01234567-8',
                        validator: _validarDui)),
                    _field(isWide, _buildTextField('Correo electrónico', _correoCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validarEmail)),
                    _field(isWide, _buildTextField('NIT', _nitCtrl,
                            validator: (_) => null)),
                    _field(isWide, _buildTextField('NRC', _nrcCtrl,
                        hint: '123456 o 123456-7',
                        validator: _validarNrc)),
                    _field(isWide, _buildFrecuenciaField()),
                  ],
                ),

                const SizedBox(height: 16),
                _buildTextField('Dirección', _direccionCtrl,
                     maxLines: 3,
                        validator: (_) => null),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Checkbox(
                      value: _estado,
                      onChanged: _guardando ? null : (val) => setState(() => _estado = val!),
                      activeColor: const Color(0xFFC0392B),
                    ),
                    const Text('Cliente activo', style: TextStyle(fontSize: 16)),
                  ],
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardarCliente,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC0392B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _guardando
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(
                            _esEdicion ? 'Guardar cambios' : 'Agregar cliente',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Itim'),
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

  Widget _field(bool isWide, Widget child) => SizedBox(width: isWide ? 340 : double.infinity, child: child);

  // ... (mantengo los métodos _buildTextField y _buildFrecuenciaField iguales que antes)

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      List<TextInputFormatter>? inputFormatters,
      String? hint,
      int maxLines = 1,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: !_guardando,
          inputFormatters: inputFormatters,
          validator: validator ?? _validarRequerido,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildFrecuenciaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frecuencia de visita', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _frecuenciaVisita,
          hint: const Text('Seleccionar...'),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (v) => v == null ? 'Este campo es obligatorio' : null,
          items: const [
            DropdownMenuItem(value: 'Frecuente', child: Text('Frecuente')),
            DropdownMenuItem(value: 'Regular', child: Text('Regular')),
            DropdownMenuItem(value: 'Muy poco', child: Text('Muy poco')),
          ],
          onChanged: _guardando ? null : (val) => setState(() => _frecuenciaVisita = val),
        ),
      ],
    );
  }
}