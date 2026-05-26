import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';
import 'package:frontend/widgets/inputs/busqueda.dart';
import 'package:frontend/widgets/modals/agregar_empleado_modal.dart';
import 'package:frontend/models/empleado_back.dart';
import 'package:frontend/services/empleado_service.dart';

class EmpleadosPage extends StatefulWidget {
  const EmpleadosPage({super.key});

  @override
  State<EmpleadosPage> createState() => _EmpleadosPageState();
}

class _EmpleadosPageState extends State<EmpleadosPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Empleado> _empleados = [];
  bool _loading = true;
  String? _error;

  static const Color _headerBg = Color(0xFFC0392B);

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarEmpleados() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await EmpleadoService.getAll();
      if (mounted) setState(() => _empleados = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _eliminarEmpleado(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar empleado'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar este empleado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: _headerBg),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await EmpleadoService.delete(id);
      await _cargarEmpleados();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  List<Empleado> get _empleadosFiltrados {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _empleados;
    return _empleados.where((e) {
      return e.nombre.toLowerCase().contains(query) ||
          e.telefono.toLowerCase().contains(query) ||
          e.dui.toLowerCase().contains(query);
    }).toList();
  }

  String _formatSueldo(double sueldo) => '\$ ${sueldo.toStringAsFixed(2)}';

  String _formatPorcentaje(double? porcentaje) =>
      porcentaje != null
          ? '${porcentaje.toStringAsFixed(0)}%'
          : 'Sin porcentaje';

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      drawer: isWide ? null : const SidebarDrawerContent(),
      appBar: isWide ? null : AppBar(title: const Text('Empleados')),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isWide)
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  'Empleados',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Itim',
                                  ),
                                ),
                              ),
                            if (isWide) const SizedBox(height: 16),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: SearchField(
                                hint: 'Buscar Empleado',
                                controller: _searchController,
                                onChanged: (val) => setState(() {}),
                              ),
                            ),
                            const SizedBox(height: 20),

                            isWide
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 25),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.15),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: _empleadosFiltrados.isEmpty
                                        ? _buildEmptyState()
                                        : _buildTable(),
                                  )
                                : _empleadosFiltrados.isEmpty
                                    ? _buildEmptyStateMobile()
                                    : _buildCardList(),

                            const SizedBox(height: 20),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: isWide
                                  ? Center(
                                      child: _AgregarEmpleadoButton(
                                          isWide: isWide,
                                          onEmpleadoAgregado:
                                              _cargarEmpleados))
                                  : _AgregarEmpleadoButton(
                                      isWide: isWide,
                                      onEmpleadoAgregado: _cargarEmpleados),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Error al cargar empleados',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_error ?? '', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _cargarEmpleados,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          _buildTableHeader(),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1_outlined,
                    size: 80, color: Colors.black54),
                SizedBox(height: 16),
                Text(
                  'NO SE HA AGREGADO NINGÚN EMPLEADO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final empleados = _empleadosFiltrados;
    return Column(
      children: [
        _buildTableHeader(),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: empleados.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final e = empleados[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.nombre,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(e.telefono,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Text(e.dui,
                          style: const TextStyle(fontSize: 13))),
                  Expanded(
                    flex: 3,
                    child: Text(_formatPorcentaje(e.porcentajeGanancia),
                        style: const TextStyle(fontSize: 13)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(_formatSueldo(e.sueldoBase),
                        style: const TextStyle(fontSize: 13)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        _AccionButton(
                          label: 'Editar',
                          color: const Color(0xFFC0392B),
                          onTap: () async {
                            await showDialog(
                              context: context,
                              builder: (context) => AgregarEmpleadoModal(
                                empleado: e,
                              ),
                            );
                            _cargarEmpleados();
                          },
                        ),
                        const SizedBox(width: 8),
                        _AccionButton(
                          label: 'Eliminar',
                          color: const Color(0xFF7B1111),
                          onTap: () => _eliminarEmpleado(e.id!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    const style = TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(color: _headerBg),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('Nombre / Teléfono', style: style)),
          Expanded(flex: 2, child: Text('DUI', style: style)),
          Expanded(
              flex: 3,
              child: Text('Porcentaje de ganancia', style: style)),
          Expanded(flex: 2, child: Text('Sueldo base', style: style)),
          Expanded(flex: 3, child: Text('ACCIONES', style: style)),
        ],
      ),
    );
  }

  Widget _buildEmptyStateMobile() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_add_alt_1_outlined,
              size: 80, color: Colors.black54),
          SizedBox(height: 16),
          Text(
            'NO SE HA AGREGADO NINGÚN EMPLEADO',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList() {
    final empleados = _empleadosFiltrados;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: empleados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final e = empleados[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: _headerBg,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              )),
                          Text(e.telefono,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _cardRow('DUI', e.dui),
                    const SizedBox(height: 6),
                    _cardRow('% Ganancia',
                        _formatPorcentaje(e.porcentajeGanancia)),
                    const SizedBox(height: 6),
                    _cardRow('Sueldo base', _formatSueldo(e.sueldoBase)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 14, right: 14, bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _AccionButton(
                            label: 'Editar',
                            color: const Color(0xFFC0392B),
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => AgregarEmpleadoModal(
                                  empleado: e,
                                ),
                              );
                              _cargarEmpleados();
                            },
                            fullWidth: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _AccionButton(
                            label: 'Eliminar',
                            color: const Color(0xFF7B1111),
                            onTap: () => _eliminarEmpleado(e.id!),
                            fullWidth: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cardRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              )),
        ),
        Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}


class _AccionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  const _AccionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  State<_AccionButton> createState() => _AccionButtonState();
}

class _AccionButtonState extends State<_AccionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = Color.lerp(widget.color, Colors.black, 0.2)!;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.fullWidth ? double.infinity : null,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? hoverColor : widget.color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Itim',
            ),
          ),
        ),
      ),
    );
  }
}


class _AgregarEmpleadoButton extends StatefulWidget {
  final bool isWide;
  final VoidCallback onEmpleadoAgregado;

  const _AgregarEmpleadoButton({
    required this.isWide,
    required this.onEmpleadoAgregado,
  });

  @override
  State<_AgregarEmpleadoButton> createState() =>
      _AgregarEmpleadoButtonState();
}

class _AgregarEmpleadoButtonState extends State<_AgregarEmpleadoButton> {
  bool _hovered = false;

  static const _base = Color(0xFFC0392B);
  static const _hover = Color(0xFF96211F);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () async {
          await showDialog(
            context: context,
            builder: (context) => const AgregarEmpleadoModal(),
          );
          widget.onEmpleadoAgregado();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.isWide ? 400 : double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: BoxDecoration(
            color: _hovered ? _hover : _base,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: _base.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: const Text(
            'Agregar nuevo empleado',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Itim',
            ),
          ),
        ),
      ),
    );
  }
}