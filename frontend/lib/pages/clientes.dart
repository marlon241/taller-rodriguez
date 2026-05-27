import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';
import 'package:frontend/widgets/inputs/busqueda.dart';
import 'package:frontend/widgets/inputs/select.dart';
import 'package:frontend/widgets/modals/agregar_cliente_modal.dart';
import 'package:frontend/models/cliente.dart';
import 'package:frontend/services/cliente_service.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _filtroFrecuencia;
  List<Cliente> _clientes = [];
  bool _cargando = true;

  static const Color _headerBg = Color(0xFFC0392B);

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarClientes() async {
    try {
      final data = await ClienteService.getAll();
      setState(() {
        _clientes = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  List<Cliente> get _clientesFiltrados {
    return _clientes.where((c) {
      final query = _searchController.text.toLowerCase();
      final matchSearch = query.isEmpty ||
          c.nombre.toLowerCase().contains(query) ||
          c.telefono.toLowerCase().contains(query) ||
          c.dui.toLowerCase().contains(query);
      final matchFrecuencia =
          _filtroFrecuencia == null || c.frecuenciaVisita == _filtroFrecuencia;
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
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isWide)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Text('Clientes',
                                style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, fontFamily: 'Itim')),
                          ),
                        if (isWide) const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: isWide
                              ? Row(children: [
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
                                    options: const ['Frecuente', 'Regular', 'Muy poco'],
                                    onChanged: (val) => setState(() => _filtroFrecuencia = val),
                                  ),
                                ])
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
                                      options: const ['Frecuente', 'Regular', 'Muy poco'],
                                      onChanged: (val) => setState(() => _filtroFrecuencia = val),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 20),

                        isWide
                            ? Container(
                                margin: const EdgeInsets.symmetric(horizontal: 25),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10))],
                                ),
                                child: _clientesFiltrados.isEmpty ? _buildEmptyState() : _buildTable(),
                              )
                            : _clientesFiltrados.isEmpty
                                ? _buildEmptyStateMobile()
                                : _buildCardList(),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: isWide
                              ? Center(child: _AgregarClienteButton(isWide: isWide, onAgregado: _cargarClientes))
                              : _AgregarClienteButton(isWide: isWide, onAgregado: _cargarClientes),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

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
                Icon(Icons.person_add_alt_1_outlined, size: 80, color: Colors.black54),
                SizedBox(height: 16),
                Text('NO SE HA AGREGADO NINGÚN CLIENTE',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(c.telefono, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Expanded(flex: 3, child: Text(c.dui, style: const TextStyle(fontSize: 13))),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _FrecuenciaChip(frecuencia: c.frecuenciaVisita),
                    ),
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
                              builder: (_) => AgregarClienteModal(cliente: c),
                            );
                            _cargarClientes();
                          },
                        ),
                        const SizedBox(width: 8),
                        _AccionButton(
                          label: 'Eliminar',
                          color: const Color(0xFF7B1111),
                          onTap: () async {
                            await ClienteService.delete(c.id!);
                            _cargarClientes();
                          },
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
    const style = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13);
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
          Expanded(flex: 3, child: Text('Frecuencia de visita', style: style)),
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
          Icon(Icons.person_add_alt_1_outlined, size: 80, color: Colors.black54),
          SizedBox(height: 16),
          Text('NO SE HA AGREGADO NINGÚN CLIENTE',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: _headerBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(c.telefono, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    _FrecuenciaChip(frecuencia: c.frecuenciaVisita),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const SizedBox(width: 80, child: Text('DUI', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500))),
                    Expanded(child: Text(c.dui, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _AccionButton(label: 'Editar', color: const Color(0xFFC0392B), onTap: () async {
                          await showDialog(context: context, builder: (_) => AgregarClienteModal(cliente: c));
                          _cargarClientes();
                        }, fullWidth: true)),
                        const SizedBox(width: 8),
                        Expanded(child: _AccionButton(label: 'Eliminar', color: const Color(0xFF7B1111), onTap: () async {
                          await ClienteService.delete(c.id!);
                          _cargarClientes();
                        }, fullWidth: true)),
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
}

// ── Chip frecuencia ──────────────────────────────────────────────────────────
class _FrecuenciaChip extends StatelessWidget {
  final String frecuencia;
  const _FrecuenciaChip({required this.frecuencia});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color text;
    switch (frecuencia) {
      case 'Frecuente': bg = const Color(0xFFDFF5E1); text = const Color(0xFF2E7D32); break;
      case 'Regular':   bg = const Color(0xFFFFF8E1); text = const Color(0xFFF9A825); break;
      default:          bg = const Color(0xFFFFEBEE); text = const Color(0xFFC62828);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(frecuencia, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: text)),
    );
  }
}

// ── Botón acción ─────────────────────────────────────────────────────────────
class _AccionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;
  const _AccionButton({required this.label, required this.color, required this.onTap, this.fullWidth = false});

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
            boxShadow: _hovered ? [BoxShadow(color: widget.color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))] : [],
          ),
          child: Text(widget.label, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Itim')),
        ),
      ),
    );
  }
}

// ── Botón agregar ─────────────────────────────────────────────────────────────
class _AgregarClienteButton extends StatefulWidget {
  final bool isWide;
  final VoidCallback onAgregado;
  const _AgregarClienteButton({required this.isWide, required this.onAgregado});

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
        onTap: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (_) => const AgregarClienteModal(),
          );
          if (result == true) widget.onAgregado();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.isWide ? 400 : double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: BoxDecoration(
            color: _hovered ? _hover : _base,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _hovered ? [BoxShadow(color: _base.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
          ),
          child: const Text('Agregar nuevo cliente', textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Itim')),
        ),
      ),
    );
  }
}