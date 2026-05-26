import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';
import 'package:frontend/widgets/inputs/busqueda.dart';
import 'package:frontend/widgets/inputs/select.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _filtroFrecuencia;

  // Datos de ejemplo — reemplazar con datos reales del backend
  final List<Map<String, String>> _clientes = [
    {
      'nombre': 'Juan Pérez',
      'telefono': '6005 5989',
      'dui': '0215-145329-102-3',
      'frecuencia': 'Regular',
    },
    {
      'nombre': 'María Gómez',
      'telefono': '6050 2116',
      'dui': '0824-987624-114-7',
      'frecuencia': 'Muy poco',
    },
    {
      'nombre': 'Jared Amaya',
      'telefono': '6444 3934',
      'dui': '0310-245108-009-1',
      'frecuencia': 'Frecuente',
    },
  ];

  static const Color _headerColor = Color(0xFFA61B1B);
  static const Color _headerBg = Color(0xFFC0392B);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _clientesFiltrados {
    return _clientes.where((c) {
      final query = _searchController.text.toLowerCase();
      final matchSearch = query.isEmpty ||
          c['nombre']!.toLowerCase().contains(query) ||
          c['telefono']!.toLowerCase().contains(query) ||
          c['dui']!.toLowerCase().contains(query);
      final matchFrecuencia =
          _filtroFrecuencia == null || c['frecuencia'] == _filtroFrecuencia;
      return matchSearch && matchFrecuencia;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      drawer: isWide ? null : const SidebarDrawerContent(),
      appBar: isWide ? null : AppBar(title: const Text('Clientes')),
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
                        'Clientes',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Itim',
                        ),
                      ),
                    ),
                  if (isWide) const SizedBox(height: 16),

                  // Barra de búsqueda y filtro
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: isWide
                        ? Row(
                            children: [
                              Expanded(
                                child: SearchField(
                                  hint: 'Buscar cliente',
                                  controller: _searchController,
                                  onChanged: (val) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilterDropdown(
                                label: 'Filtrar por:',
                                value: _filtroFrecuencia,
                                options: const [
                                  'Frecuente',
                                  'Regular',
                                  'Muy poco',
                                ],
                                onChanged: (val) =>
                                    setState(() => _filtroFrecuencia = val),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SearchField(
                                hint: 'Buscar cliente',
                                controller: _searchController,
                                onChanged: (val) => setState(() {}),
                              ),
                              const SizedBox(height: 10),
                              FilterDropdown(
                                label: 'Filtrar por:',
                                value: _filtroFrecuencia,
                                options: const [
                                  'Frecuente',
                                  'Regular',
                                  'Muy poco',
                                ],
                                onChanged: (val) =>
                                    setState(() => _filtroFrecuencia = val),
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
                          child: _clientesFiltrados.isEmpty
                              ? _buildEmptyState()
                              : _buildTable(),
                        )
                      : _clientesFiltrados.isEmpty
                          ? _buildEmptyStateMobile()
                          : _buildCardList(),

                  const SizedBox(height: 20),

                  // Botón agregar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: isWide
                        ? Center(child: _AgregarClienteButton(isWide: isWide))
                        : _AgregarClienteButton(isWide: isWide),
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
      height: 400,
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
                  'NO SE HA AGREGADO NINGÚN CLIENTE',
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
    final clientes = _clientesFiltrados;
    return Column(
      children: [
        _buildTableHeader(),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: clientes.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final c = clientes[index];
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
                        Text(c['nombre']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(c['telefono']!,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                  // DUI
                  Expanded(
                    flex: 3,
                    child: Text(c['dui']!,
                        style: const TextStyle(fontSize: 13)),
                  ),
                  // Frecuencia
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _FrecuenciaChip(frecuencia: c['frecuencia']!),
                    ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('Nombre / Teléfono', style: style)),
          Expanded(flex: 3, child: Text('DUI', style: style)),
          Expanded(
              flex: 3, child: Text('Frecuencia de visita', style: style)),
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
            'NO SE HA AGREGADO NINGÚN CLIENTE',
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
    final clientes = _clientesFiltrados;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: clientes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final c = clientes[index];
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
                            c['nombre']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            c['telefono']!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _FrecuenciaChip(frecuencia: c['frecuencia']!),
                  ],
                ),
              ),

              // Cuerpo
              Padding(
                padding: const EdgeInsets.all(14),
                child: _cardRow('DUI', c['dui']!),
              ),

              // Acciones
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
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
// CHIP DE FRECUENCIA
// ─────────────────────────────────────────────────────────────────────────────
class _FrecuenciaChip extends StatelessWidget {
  final String frecuencia;
  const _FrecuenciaChip({required this.frecuencia});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color text;

    switch (frecuencia) {
      case 'Frecuente':
        bg = const Color(0xFFDFF5E1);
        text = const Color(0xFF2E7D32);
        break;
      case 'Regular':
        bg = const Color(0xFFFFF8E1);
        text = const Color(0xFFF9A825);
        break;
      case 'Muy poco':
      default:
        bg = const Color(0xFFFFEBEE);
        text = const Color(0xFFC62828);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        frecuencia,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
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
// BOTÓN AGREGAR NUEVO CLIENTE con hover
// ─────────────────────────────────────────────────────────────────────────────
class _AgregarClienteButton extends StatefulWidget {
  final bool isWide;
  const _AgregarClienteButton({required this.isWide});

  @override
  State<_AgregarClienteButton> createState() => _AgregarClienteButtonState();
}

class _AgregarClienteButtonState extends State<_AgregarClienteButton> {
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
          // abrir modal/pantalla de agregar cliente
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
            'Agregar nuevo cliente',
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