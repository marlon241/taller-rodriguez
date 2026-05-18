import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';
import 'package:frontend/widgets/inputs/busqueda.dart';
import 'package:frontend/widgets/inputs/select.dart';

class VehiculosPage extends StatefulWidget {
  const VehiculosPage({super.key});

  @override
  State<VehiculosPage> createState() => _VehiculosPageState();
}

class _VehiculosPageState extends State<VehiculosPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _filtroEstado;
  bool _mostrarEntregados = false;

  // Datos de ejemplo — reemplazar con datos reales del backend
  final List<Map<String, String>> _vehiculos = [
    {
      'id': '#001',
      'placa': 'ABC-123',
      'cliente': 'Juan Pérez',
      'modelo': 'Toyota Corolla 2022',
      'estado': 'En revisión',
      'ingreso': '05 Dic 2025',
      'entregado': 'false',
    },
    {
      'id': '#002',
      'placa': 'XYZ-789',
      'cliente': 'María Gómez',
      'modelo': 'Honda Civic 2023',
      'estado': 'Reparando',
      'ingreso': '10 Dic 2025',
      'entregado': 'false',
    },
    {
      'id': '#003',
      'placa': 'PHK-456',
      'cliente': 'Jared Amaya',
      'modelo': 'BMW Serie 3 2021',
      'estado': 'Reparando',
      'ingreso': '24 Dic 2025',
      'entregado': 'false',
    },
  ];

  // Header color: rosa claro con texto rojo (mismo que inventario)
  static const Color _headerBg = Color(0xFFFFF0F0);
  static const Color _headerText = Color(0xFFA61B1B);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _vehiculosFiltrados {
    final query = _searchController.text.toLowerCase();
    return _vehiculos.where((v) {
      final esEntregado = v['entregado'] == 'true';
      if (_mostrarEntregados != esEntregado) return false;

      final matchSearch = query.isEmpty ||
          v['placa']!.toLowerCase().contains(query) ||
          v['cliente']!.toLowerCase().contains(query) ||
          v['modelo']!.toLowerCase().contains(query) ||
          v['id']!.toLowerCase().contains(query);

      final matchEstado =
          _filtroEstado == null || v['estado'] == _filtroEstado;

      return matchSearch && matchEstado;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      drawer: isWide ? null : const SidebarDrawerContent(),
      appBar: isWide ? null : AppBar(title: const Text('Vehículos taller')),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título + toggle
                  if (isWide)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          const Text(
                            'Vehiculos  en el taller',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Itim',
                            ),
                          ),
                          const Spacer(),
                          _buildToggle(),
                        ],
                      ),
                    ),
                  if (isWide) const SizedBox(height: 16),

                  // En móvil el toggle va debajo del título
                  if (!isWide)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 8),
                      child: _buildToggle(),
                    ),

                  // Barra de búsqueda y filtro
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: isWide
                        ? Row(
                            children: [
                              Expanded(
                                child: SearchField(
                                  hint: 'Buscar vehiculo',
                                  controller: _searchController,
                                  onChanged: (val) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilterDropdown(
                                label: 'Filtrar por:',
                                value: _filtroEstado,
                                options: const [
                                  'En revisión',
                                  'Reparando',
                                  'Listo',
                                  'Entregado',
                                ],
                                onChanged: (val) =>
                                    setState(() => _filtroEstado = val),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SearchField(
                                hint: 'Buscar vehiculo',
                                controller: _searchController,
                                onChanged: (val) => setState(() {}),
                              ),
                              const SizedBox(height: 10),
                              FilterDropdown(
                                label: 'Filtrar por:',
                                value: _filtroEstado,
                                options: const [
                                  'En revisión',
                                  'Reparando',
                                  'Listo',
                                  'Entregado',
                                ],
                                onChanged: (val) =>
                                    setState(() => _filtroEstado = val),
                              ),
                            ],
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
                          child: _vehiculosFiltrados.isEmpty
                              ? _buildEmptyState()
                              : _buildTable(),
                        )
                      : _vehiculosFiltrados.isEmpty
                          ? _buildEmptyStateMobile()
                          : _buildCardList(),

                  const SizedBox(height: 20),

                  // Botón agregar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: isWide
                        ? Center(
                            child: _AgregarVehiculoButton(isWide: isWide))
                        : _AgregarVehiculoButton(isWide: isWide),
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
  // TOGGLE "Cambiar a entregados"
  // ─────────────────────────────────────────
  Widget _buildToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Cambiar a entregados',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(width: 8),
        Switch(
          value: _mostrarEntregados,
          activeColor: const Color(0xFFC0392B),
          onChanged: (val) => setState(() {
            _mostrarEntregados = val;
            _filtroEstado = null;
          }),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // MODO ESCRITORIO — tabla
  // ─────────────────────────────────────────

  Widget _buildEmptyState() {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          _buildTableHeader(),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_outlined,
                    size: 80, color: Colors.black54),
                SizedBox(height: 16),
                Text(
                  'NO SE HA AGREGADO NINGÚN VEHÍCULO',
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
    final vehiculos = _vehiculosFiltrados;
    return Column(
      children: [
        _buildTableHeader(),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vehiculos.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final v = vehiculos[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // ID
                  SizedBox(
                    width: 48,
                    child: Text(v['id']!,
                        style: const TextStyle(fontSize: 13)),
                  ),
                  // Placa
                  SizedBox(
                    width: 72,
                    child: Text(
                      v['placa']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  // Cliente / Modelo
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v['cliente']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(v['modelo']!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  // Estado
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _EstadoChip(estado: v['estado']!),
                    ),
                  ),
                  // Ingreso
                  Expanded(
                    flex: 2,
                    child: Text(v['ingreso']!,
                        style: const TextStyle(fontSize: 13)),
                  ),
                  // Acciones
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        _AccionButton(
                          label: 'Visualizar',
                          color: const Color(0xFF2979FF),
                          onTap: () {},
                        ),
                        const SizedBox(width: 6),
                        _AccionButton(
                          label: 'Editar',
                          color: const Color(0xFFC0392B),
                          onTap: () {},
                        ),
                        const SizedBox(width: 6),
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
      color: _headerText,
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: _headerBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 48, child: Text('ID', style: style)),
          SizedBox(width: 72, child: Text('PLACA', style: style)),
          Expanded(flex: 3, child: Text('CLIENTE / MODELO', style: style)),
          Expanded(flex: 2, child: Text('ESTADO', style: style)),
          Expanded(flex: 2, child: Text('INGRESO', style: style)),
          Expanded(flex: 4, child: Text('ACCIONES', style: style)),
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
          Icon(Icons.directions_car_outlined, size: 80, color: Colors.black54),
          SizedBox(height: 16),
          Text(
            'NO SE HA AGREGADO NINGÚN VEHÍCULO',
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
    final vehiculos = _vehiculosFiltrados;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: vehiculos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final v = vehiculos[index];
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
              // Cabecera
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
                    Text(
                      v['id']!,
                      style: const TextStyle(
                        color: _headerText,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      v['placa']!,
                      style: const TextStyle(
                        color: _headerText,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        v['cliente']!,
                        style: const TextStyle(
                          color: _headerText,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _EstadoChip(estado: v['estado']!),
                  ],
                ),
              ),

              // Cuerpo
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _cardRow('Modelo', v['modelo']!),
                    const SizedBox(height: 6),
                    _cardRow('Ingreso', v['ingreso']!),
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
                            label: 'Visualizar',
                            color: const Color(0xFF2979FF),
                            onTap: () {},
                            fullWidth: true,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _AccionButton(
                            label: 'Editar',
                            color: const Color(0xFFC0392B),
                            onTap: () {},
                            fullWidth: true,
                          ),
                        ),
                        const SizedBox(width: 6),
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
          width: 80,
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
// CHIP DE ESTADO
// ─────────────────────────────────────────────────────────────────────────────
class _EstadoChip extends StatelessWidget {
  final String estado;
  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color text;

    switch (estado) {
      case 'En revisión':
        bg = const Color(0xFFFFF8E1);
        text = const Color(0xFFF9A825);
        break;
      case 'Reparando':
        bg = const Color(0xFFE3F2FD);
        text = const Color(0xFF1565C0);
        break;
      case 'Listo':
        bg = const Color(0xFFDFF5E1);
        text = const Color(0xFF2E7D32);
        break;
      case 'Entregado':
      default:
        bg = const Color(0xFFEEEEEE);
        text = const Color(0xFF616161);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTÓN DE ACCIÓN con hover
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              fontSize: 12,
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
// BOTÓN AGREGAR VEHÍCULO con hover
// ─────────────────────────────────────────────────────────────────────────────
class _AgregarVehiculoButton extends StatefulWidget {
  final bool isWide;
  const _AgregarVehiculoButton({required this.isWide});

  @override
  State<_AgregarVehiculoButton> createState() => _AgregarVehiculoButtonState();
}

class _AgregarVehiculoButtonState extends State<_AgregarVehiculoButton> {
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
          // TODO (navegación): abrir modal/pantalla de agregar vehículo
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
            'Agregar vehiculo',
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