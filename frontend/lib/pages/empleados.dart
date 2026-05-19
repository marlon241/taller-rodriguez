import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';
import 'package:frontend/widgets/inputs/busqueda.dart';
import 'package:frontend/widgets/modals/agregar_empleado_modal.dart';
import 'package:frontend/widgets/modals/exito_modal.dart';

class EmpleadosPage extends StatefulWidget {
  const EmpleadosPage({super.key});

  @override
  State<EmpleadosPage> createState() => _EmpleadosPageState();
}

class _EmpleadosPageState extends State<EmpleadosPage> {
  final TextEditingController _searchController = TextEditingController();

  // Datos de ejemplo — reemplazar con datos reales del backend
  final List<Map<String, String>> _empleados = [
    // {
    //   'nombre': 'Juan Pérez',
    //   'telefono': '6005 5989',
    //   'dui': '03945218-6',
    //   'porcentaje': '65%',
    //   'sueldo': '\$ 600.00',
    // },
    // {
    //   'nombre': 'María Gómez',
    //   'telefono': '6050 2116',
    //   'dui': '08412955-3',
    //   'porcentaje': 'Sin porcentaje',
    //   'sueldo': '\$ 400.00',
    // },
    // {
    //   'nombre': 'Jared Amaya',
    //   'telefono': '6444 3934',
    //   'dui': '01763824-9',
    //   'porcentaje': 'Sin porcentaje',
    //   'sueldo': '\$ 360.00',
    // },
  ];

  static const Color _headerBg = Color(0xFFC0392B);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _empleadosFiltrados {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _empleados;
    return _empleados.where((e) {
      return e['nombre']!.toLowerCase().contains(query) ||
          e['telefono']!.toLowerCase().contains(query) ||
          e['dui']!.toLowerCase().contains(query);
    }).toList();
  }

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  if (isWide)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
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

                  // Barra de búsqueda
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: SearchField(
                      hint: 'Buscar Empleado',
                      controller: _searchController,
                      onChanged: (val) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tabla (wide) o Tarjetas (móvil)
                  isWide
                      ? Container(
                          margin: const EdgeInsets.symmetric(horizontal: 25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
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

                  // Botón agregar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: isWide
                        ? Center(
                            child: _AgregarEmpleadoButton(isWide: isWide))
                        : _AgregarEmpleadoButton(isWide: isWide),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // MODO ESCRITORIO — tabla
  // ─────────────────────────────────────────

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
                  // Nombre + teléfono
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e['nombre']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          e['telefono']!,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  // DUI
                  Expanded(
                    flex: 2,
                    child: Text(e['dui']!,
                        style: const TextStyle(fontSize: 13)),
                  ),
                  // Porcentaje de ganancia
                  Expanded(
                    flex: 3,
                    child: Text(e['porcentaje']!,
                        style: const TextStyle(fontSize: 13)),
                  ),
                  // Sueldo base
                  Expanded(
                    flex: 2,
                    child: Text(e['sueldo']!,
                        style: const TextStyle(fontSize: 13)),
                  ),
                  // Acciones
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        _AccionButton(
                          label: 'Editar',
                          color: const Color(0xFFC0392B),
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _AccionButton(
                          label: 'Eliminar',
                          color: const Color(0xFF7B1111),
                          onTap: () {},
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
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: _headerBg,
      ),
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

  // ─────────────────────────────────────────
  // MODO MÓVIL — tarjetas
  // ─────────────────────────────────────────

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
              // Cabecera roja
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          Text(
                            e['nombre']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            e['telefono']!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Cuerpo
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _cardRow('DUI', e['dui']!),
                    const SizedBox(height: 6),
                    _cardRow('% Ganancia', e['porcentaje']!),
                    const SizedBox(height: 6),
                    _cardRow('Sueldo base', e['sueldo']!),
                  ],
                ),
              ),

              // Acciones
              Padding(
                padding:
                    const EdgeInsets.only(left: 14, right: 14, bottom: 14),
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
                            onTap: () {},
                            fullWidth: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _AccionButton(
                            label: 'Eliminar',
                            color: const Color(0xFF7B1111),
                            onTap: () {},
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
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTÓN DE ACCIÓN (Editar / Eliminar) con hover
// ─────────────────────────────────────────────────────────────────────────────
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

// ─────────────────────────────────────────────────────────────────────────────
// BOTÓN AGREGAR NUEVO EMPLEADO con hover
// ─────────────────────────────────────────────────────────────────────────────
class _AgregarEmpleadoButton extends StatefulWidget {
  final bool isWide;
  const _AgregarEmpleadoButton({required this.isWide});

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
        onTap: () {
  showDialog(
    context: context,
    builder: (context) => const AgregarEmpleadoModal(),
  );
},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.isWide ? 400 : double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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