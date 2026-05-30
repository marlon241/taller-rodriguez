import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/cliente.dart';
import '../../models/empleado_back.dart';
import '../../services/cliente_service.dart';
import '../../services/Empleado_service.dart';
import '../../services/vehiculo_service.dart';

class AgregarVehiculoModal extends StatefulWidget {
  final VoidCallback onVehiculoAgregado;
  const AgregarVehiculoModal({super.key, required this.onVehiculoAgregado});

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

  List<Cliente> _clientes = [];
  Cliente? _clienteSeleccionado;
  List<Empleado> _empleados = [];
  Empleado? _empleadoSeleccionado;
  String? _estado;

  XFile? _imagenVehiculo;
  XFile? _imagenTarjeta;
  bool _subiendoImagen = false;
  bool _guardando = false;
  bool _cargandoClientes = true;
  bool _cargandoEmpleados = true;

  @override
  void initState() {
    super.initState();
    _cargarClientes();
    _cargarEmpleados();
  }

  Future<void> _cargarClientes() async {
    try {
      final clientes = await ClienteService.getAll();
      if (mounted) {
        setState(() {
          _clientes = clientes.where((c) => c.estado).toList();
          _cargandoClientes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargandoClientes = false);
      }
    }
  }

  Future<void> _cargarEmpleados() async {
    try {
      final empleados = await EmpleadoService.getAll();
      if (mounted) {
        setState(() {
          _empleados = empleados.where((e) => e.estado).toList();
          _cargandoEmpleados = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargandoEmpleados = false);
      }
    }
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

  Future<void> _seleccionarImagen(bool esVehiculo) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60, maxWidth: 800, maxHeight: 800);
    if (picked == null) return;
    setState(() {
      if (esVehiculo) { _imagenVehiculo = picked; } else { _imagenTarjeta = picked; }
    });
  }

  Future<String?> _subirImagen(XFile imagen, String carpeta, String placa) async {
    try {
      final bytes = await imagen.readAsBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '$carpeta/${placa}_$timestamp.jpg';
      await Supabase.instance.client.storage.from('vehiculos').uploadBinary(
        path, bytes, fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );
      return Supabase.instance.client.storage.from('vehiculos').getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  Future<void> _agregarVehiculo() async {
    if (_modeloCtrl.text.isEmpty || _marcaCtrl.text.isEmpty || _placaCtrl.text.isEmpty || _anioCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos requeridos: modelo, marca, placa y año'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _guardando = true);

    String? urlVehiculo;
    String? urlTarjeta;

    if (_imagenVehiculo != null) {
      setState(() => _subiendoImagen = true);
      urlVehiculo = await _subirImagen(_imagenVehiculo!, 'imagenes', _placaCtrl.text);
      setState(() => _subiendoImagen = false);
    }

    if (_imagenTarjeta != null) {
      setState(() => _subiendoImagen = true);
      urlTarjeta = await _subirImagen(_imagenTarjeta!, 'tarjetas', _placaCtrl.text);
      setState(() => _subiendoImagen = false);
    }

    final datos = {
      'modelo': _modeloCtrl.text,
      'marca': _marcaCtrl.text,
      'placa': _placaCtrl.text,
      'anio': int.tryParse(_anioCtrl.text) ?? 0,
      'diagnostico': _diagnosticoCtrl.text,
      'estado': _estado ?? 'En revisión',
      'fecha_ingreso': _fechaIngresoCtrl.text.isNotEmpty ? _parseFecha(_fechaIngresoCtrl.text) : DateTime.now().toIso8601String(),
      'fecha_salida': _fechaSalidaCtrl.text.isNotEmpty ? _parseFecha(_fechaSalidaCtrl.text) : null,
      if (_clienteSeleccionado != null) 'id_cliente': _clienteSeleccionado!.id,
      if (_empleadoSeleccionado != null) 'id_empleado': _empleadoSeleccionado!.id,
      if (urlVehiculo != null) 'url_imagen_vehiculo': urlVehiculo,
      if (urlTarjeta != null) 'url_tarjeta_circulacion': urlTarjeta,
    };

    final result = await VehiculoService.crearVehiculo(datos);
    setState(() => _guardando = false);

    if (result['success'] == true) {
      widget.onVehiculoAgregado();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo agregado correctamente'), backgroundColor: Color(0xFFC0392B)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Error al agregar'), backgroundColor: Colors.red),
      );
    }
  }

  String _parseFecha(String fecha) {
    final partes = fecha.split('/');
    if (partes.length == 3) {
      return '${partes[2]}-${partes[1].padLeft(2, '0')}-${partes[0].padLeft(2, '0')}T00:00:00';
    }
    return DateTime.now().toIso8601String();
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
                  child: Text("Agregar Vehículo", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Itim')),
                ),
                const SizedBox(height: 28),

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

                isWide
                    ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _buildClienteDropdown(),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/clientes');
                            },
                            child: const Text("Agregar cliente nuevo"),
                          ),
                        ])),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _buildEmpleadoDropdown(),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/empleados');
                            },
                            child: const Text("Agregar empleado nuevo"),
                          ),
                        ])),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdown("Estado", _estado, ["En revisión", "Reparando", "Listo"], (val) => setState(() => _estado = val))),
                      ])
                    : Column(children: [
                        _buildClienteDropdown(),
                        const SizedBox(height: 14),
                        _buildEmpleadoDropdown(),
                        const SizedBox(height: 14),
                        _buildDropdown("Estado", _estado, ["En revisión", "Reparando", "Listo"], (val) => setState(() => _estado = val)),
                      ]),
                const SizedBox(height: 16),

                isWide
                    ? Row(children: [
                        Expanded(child: _buildTextField("Año del vehículo", _anioCtrl, keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFechaField("Fecha de ingreso", _fechaIngresoCtrl)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFechaField("Fecha de salida", _fechaSalidaCtrl)),
                      ])
                    : Column(children: [
                        _buildTextField("Año del vehículo", _anioCtrl, keyboardType: TextInputType.number),
                        const SizedBox(height: 14),
                        _buildFechaField("Fecha de ingreso", _fechaIngresoCtrl),
                        const SizedBox(height: 14),
                        _buildFechaField("Fecha de salida", _fechaSalidaCtrl),
                      ]),
                const SizedBox(height: 24),

                isWide
                    ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 2, child: _buildDiagnostico()),
                        const SizedBox(width: 20),
                        Expanded(flex: 1, child: Column(children: [
                          const SizedBox(height: 28),
                          _botonImagen("Foto del vehículo", _imagenVehiculo, true),
                          const SizedBox(height: 12),
                          _botonImagen("Tarjeta de circulación", _imagenTarjeta, false),
                        ])),
                      ])
                    : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        _buildDiagnostico(),
                        const SizedBox(height: 12),
                        _botonImagen("Foto del vehículo", _imagenVehiculo, true),
                        const SizedBox(height: 12),
                        _botonImagen("Tarjeta de circulación", _imagenTarjeta, false),
                      ]),
                const SizedBox(height: 32),

                Center(
                  child: SizedBox(
                    width: 320,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _agregarVehiculo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC0392B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _guardando
                          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                              const SizedBox(width: 12),
                              Text(_subiendoImagen ? 'Subiendo imágenes...' : 'Guardando...', style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Itim')),
                            ])
                          : const Text("Agregar vehículo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Itim', color: Colors.white)),
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

  Widget _botonImagen(String label, XFile? imagenSeleccionada, bool esVehiculo) {
    final tieneImagen = imagenSeleccionada != null;
    return GestureDetector(
      onTap: () => _seleccionarImagen(esVehiculo),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: tieneImagen ? const Color(0xFFDFF5E1) : const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: tieneImagen ? const Color(0xFF2E7D32) : const Color(0xFFC0392B)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(tieneImagen ? Icons.check_circle : Icons.add_a_photo, color: tieneImagen ? const Color(0xFF2E7D32) : const Color(0xFFC0392B), size: 20),
          const SizedBox(width: 8),
          Flexible(child: Text(
            tieneImagen ? '✓ ${imagenSeleccionada.name}' : label,
            style: TextStyle(color: tieneImagen ? const Color(0xFF2E7D32) : const Color(0xFFC0392B), fontWeight: FontWeight.w600, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          )),
        ]),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value,
        hint: Text("Seleccionar $label"),
        isExpanded: true,
        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    ]);
  }

  Widget _buildClienteDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Cliente", style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      _cargandoClientes
          ? DropdownButtonFormField<String>(
              value: null,
              hint: const Text("Cargando clientes..."),
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: const [],
              onChanged: null,
            )
          : DropdownButtonFormField<Cliente>(
              value: _clienteSeleccionado,
              hint: const Text("Seleccionar cliente"),
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _clientes.map((cliente) {
                return DropdownMenuItem<Cliente>(
                  value: cliente,
                  child: Text(cliente.nombre),
                );
              }).toList(),
              onChanged: (cliente) {
                setState(() => _clienteSeleccionado = cliente);
              },
            ),
    ]);
  }

  Widget _buildEmpleadoDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Empleado asignado", style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      _cargandoEmpleados
          ? DropdownButtonFormField<String>(
              value: null,
              hint: const Text("Cargando empleados..."),
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: const [],
              onChanged: null,
            )
          : DropdownButtonFormField<Empleado>(
              value: _empleadoSeleccionado,
              hint: const Text("Seleccionar empleado"),
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _empleados.map((empleado) {
                return DropdownMenuItem<Empleado>(
                  value: empleado,
                  child: Text(empleado.nombre),
                );
              }).toList(),
              onChanged: (empleado) {
                setState(() => _empleadoSeleccionado = empleado);
              },
            ),
    ]);
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      ),
    ]);
  }

  Widget _buildDiagnostico() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Diagnóstico", style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
        controller: _diagnosticoCtrl,
        maxLines: 5,
        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), hintText: "Escriba el diagnóstico inicial del vehículo..."),
      ),
    ]);
  }

  Widget _buildFechaField(String label, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
          if (picked != null) {
            setState(() {
              controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
            });
          }
        },
      ),
    ]);
  }
}