import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';
import 'package:frontend/services/proveedor_api.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _nitController = TextEditingController();
  String? _locacionSeleccionada;
  final ProveedorApi _api = ProveedorApi();

  final List<String> _locaciones = ['Nacional', 'Internacional'];

  List<Map<String, dynamic>> _proveedores = [];

  bool _isEditing = false;
  int? _editandoId;

  @override
  void initState() {
    super.initState();
    _cargarProveedores();
  }

  Future<void> _cargarProveedores() async {
    final datos = await _api.obtenerProveedores();
    setState(() {
      _proveedores = datos;
    });
  }

  void _resetForm() {
    _nombreController.clear();
    _telefonoController.clear();
    _correoController.clear();
    _nitController.clear();
    setState(() {
      _locacionSeleccionada = null;
      _isEditing = false;
      _editandoId = null;
    });
  }

  Future<void> _guardarProveedor() async {
    if (_nombreController.text.isEmpty || _telefonoController.text.isEmpty || _locacionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete los campos obligatorios')),
      );
      return;
    }

    final data = {
      'nombre': _nombreController.text,
      'telefono': _telefonoController.text,
      'correo': _correoController.text,
      'locacion': _locacionSeleccionada,
      if (_locacionSeleccionada == 'Nacional') 'nit': _nitController.text,
    };

    bool success;
    if (_isEditing && _editandoId != null) {
      success = (await _api.actualizarProveedor(_editandoId!, data))['success'] == true;
    } else {
      success = (await _api.crearProveedor(data))['success'] == true;
    }

    if (success) {
      final bool wasEditing = _isEditing;
      _resetForm();
      _cargarProveedores();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(wasEditing ? 'Proveedor actualizado exitosamente' : 'Proveedor creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar proveedor')),
        );
      }
    }
  }

  void _editarProveedor(Map<String, dynamic> proveedor) {
    setState(() {
      _nombreController.text = proveedor['nombre'] ?? '';
      _telefonoController.text = proveedor['telefono'] ?? '';
      _correoController.text = proveedor['correo'] ?? '';
      _nitController.text = proveedor['nit'] ?? '';
      _locacionSeleccionada = proveedor['locacion'];
      _isEditing = true;
      _editandoId = proveedor['id'];
    });
  }

  Future<void> _eliminarProveedor(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este proveedor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final resultado = await _api.eliminarProveedor(id);
      if (resultado['success'] == true) {
        _cargarProveedores();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proveedor eliminado exitosamente'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['message'] ?? 'Error al eliminar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _nitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      appBar: isWide ? null : AppBar(title: const Text('Proveedores')),
      drawer: isWide ? null : const SidebarDrawerContent(),
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWide)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        'Proveedores',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Itim',
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  isWide ? _buildWideLayout() : _buildMobileLayout(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildFormPanel()),
          const SizedBox(width: 24),
          Expanded(flex: 3, child: _buildTablePanel()),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildFormPanel(),
          const SizedBox(height: 20),
          _buildTablePanel(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFormPanel() {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Agregar proveedor",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Itim',
              ),
            ),
            const SizedBox(height: 24),

            // Nombre y Teléfono
            isWide
                ? Row(
                    children: [
                      Expanded(child: _buildTextField("Nombre del proveedor", _nombreController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField("Teléfono", _telefonoController)),
                    ],
                  )
                : Column(
                    children: [
                      _buildTextField("Nombre del proveedor", _nombreController),
                      const SizedBox(height: 14),
                      _buildTextField("Teléfono", _telefonoController),
                    ],
                  ),
            const SizedBox(height: 14),

            // Locación y Correo
            isWide
                ? Row(
                    children: [
                      Expanded(child: _buildDropdown()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField("Correo electrónico", _correoController)),
                    ],
                  )
                : Column(
                    children: [
                      _buildDropdown(),
                      const SizedBox(height: 14),
                      _buildTextField("Correo electrónico", _correoController),
                    ],
                  ),

            // NIT solo si es Nacional
            if (_locacionSeleccionada == 'Nacional') ...[
              const SizedBox(height: 14),
              _buildTextField("NIT", _nitController),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _guardarProveedor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isEditing ? 'Actualizar Proveedor' : 'Agregar Proveedor',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Itim',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontFamily: 'Itim')),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Locación",
            style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Itim')),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _locacionSeleccionada,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          items: _locaciones
              .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
              .toList(),
          onChanged: (val) => setState(() {
            _locacionSeleccionada = val;
            // Limpiar NIT si cambia a Internacional
            if (val != 'Nacional') _nitController.clear();
          }),
        ),
      ],
    );
  }

  Widget _buildTablePanel() {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header rojo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: isWide
                ? const Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text("Proveedor",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text("Locación",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text("Acciones",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                    ],
                  )
                : const SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Proveedores",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Itim'),
                    ),
                  ),
          ),

          // Filas
          if (_proveedores.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No hay proveedores registrados',
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            )
          else if (isWide)
            ..._proveedores.map((p) => _buildTableRow(p)).toList()
          else
            ..._proveedores.map((p) => _buildProveedorCard(p)).toList(),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> proveedor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(proveedor['nombre']?.toString() ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Expanded(
                flex: 2,
                child: Text(proveedor['locacion']?.toString() ?? '',
                    textAlign: TextAlign.center),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _editarProveedor(proveedor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Editar",
                          style:
                              TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _eliminarProveedor(proveedor['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF880E4F),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Eliminar",
                          style:
                              TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildProveedorCard(Map<String, dynamic> proveedor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      proveedor['nombre']?.toString() ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      proveedor['locacion']?.toString() ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(proveedor['correo']?.toString() ?? '',
                  style:
                      const TextStyle(color: Colors.black54, fontSize: 13)),
              Text(proveedor['telefono']?.toString() ?? '',
                  style:
                      const TextStyle(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _editarProveedor(proveedor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Editar"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _eliminarProveedor(proveedor['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF880E4F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Eliminar"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}