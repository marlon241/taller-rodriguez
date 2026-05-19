import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';
import 'package:frontend/widgets/inputs/busqueda.dart';
import 'package:frontend/widgets/inputs/select.dart';
import 'package:frontend/widgets/modals/agregar_producto_modal.dart';
import 'package:frontend/widgets/modals/entrada_stock_modal.dart';
import 'package:frontend/widgets/modals/salida_stock_modal.dart';
import 'package:frontend/widgets/modals/editar_producto_modal.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _filtroProducto;
  String? _filtroProveedor;

  final List<Map<String, String>> _productos = [
    {
      'id': '1',
      'producto': 'Bujia 10W-40',
      'stock': '20',
      'compra': '\$5.00',
      'venta': '\$8.00',
      'proveedor': 'Proveedor B',
      'descripcion': 'Bujia de encendido',
      'clasificacion': 'Lubricantes',
    },
    {
      'id': '2',
      'producto': 'Aceite de caja',
      'stock': '15',
      'compra': '\$10.00',
      'venta': '\$15.00',
      'proveedor': 'Proveedor A',
      'descripcion': 'Aceite para caja',
      'clasificacion': 'Lubricantes',
    },
  ];

  static const Color _headerColor = Color(0xFFA61B1B);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      drawer: isWide ? null : const SidebarDrawerContent(),
      appBar: isWide ? null : AppBar(title: const Text('Inventario')),
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
                        'Inventario',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Itim',
                        ),
                      ),
                    ),
                  if (isWide) const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: isWide
                        ? Row(
                            children: [
                              Expanded(
                                child: SearchField(
                                  hint: 'Buscar producto',
                                  controller: _searchController,
                                  onChanged: (val) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilterDropdown(
                                label: 'Filtrar productos:',
                                value: _filtroProducto,
                                options: const ['Lubricantes', 'Frenos', 'Motor', 'Eléctrico'],
                                onChanged: (val) => setState(() => _filtroProducto = val),
                              ),
                              const SizedBox(width: 12),
                              FilterDropdown(
                                label: 'Filtrar por proveedor:',
                                value: _filtroProveedor,
                                options: const ['Proveedor A', 'Proveedor B', 'Proveedor C'],
                                onChanged: (val) => setState(() => _filtroProveedor = val),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SearchField(
                                hint: 'Buscar producto',
                                controller: _searchController,
                                onChanged: (val) => setState(() {}),
                              ),
                              const SizedBox(height: 10),
                              FilterDropdown(
                                label: 'Filtrar productos:',
                                value: _filtroProducto,
                                options: const ['Lubricantes', 'Frenos', 'Motor', 'Eléctrico'],
                                onChanged: (val) => setState(() => _filtroProducto = val),
                              ),
                              const SizedBox(height: 10),
                              FilterDropdown(
                                label: 'Filtrar por proveedor:',
                                value: _filtroProveedor,
                                options: const ['Proveedor A', 'Proveedor B', 'Proveedor C'],
                                onChanged: (val) => setState(() => _filtroProveedor = val),
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: _productos.isEmpty ? _buildEmptyState() : _buildTable(),
                        )
                      : _productos.isEmpty
                          ? _buildEmptyStateMobile()
                          : _buildCardList(),

                  const SizedBox(height: 20),

                  // Botón agregar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Align(
                      alignment: isWide ? Alignment.centerRight : Alignment.center,
                      child: _AgregarButton(
                        isWide: isWide,
                        onTap: () => mostrarModalAgregarProducto(context),
                      ),
                    ),
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
  // MODO ESCRITORIO
  // ─────────────────────────────────────────

  Widget _buildEmptyState() {
    return SizedBox(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTableHeader(),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 80, color: Colors.black87),
                SizedBox(height: 16),
                Text(
                  'NO SE HA AGREGADO NINGÚN PRODUCTO\nAL INVENTARIO',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Column(
      children: [
        _buildTableHeader(),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _productos.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final p = _productos[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _cell(p['id']!),
                  _cell(p['producto']!),
                  _cell(p['stock']!),
                  _cell(p['compra']!),
                  _cell(p['venta']!),
                  _cell(p['proveedor']!),
                  _cell(p['descripcion']!),
                  _cell(p['clasificacion']!),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      children: [
                        _accionBtn('Editar', Icons.edit, Colors.blue, () => mostrarModalEditarProducto(context)),
                        _accionBtn('Agregar Stock', Icons.add, Colors.green, () => mostrarModalEntradaStock(context)),
                        _accionBtn('Salida Stock', Icons.remove, Colors.orange, () => mostrarModalSalidaStock(context)),
                        _accionBtn('Eliminar', Icons.delete, Colors.red, () {}),
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
    const style = TextStyle(color: _headerColor, fontWeight: FontWeight.bold, fontSize: 13);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: const Row(
        children: [
          Expanded(child: Text('Id', style: style)),
          Expanded(child: Text('Producto', style: style)),
          Expanded(child: Text('Stock', style: style)),
          Expanded(child: Text('Compra', style: style)),
          Expanded(child: Text('Venta', style: style)),
          Expanded(child: Text('Proveedor', style: style)),
          Expanded(child: Text('Descripción', style: style)),
          Expanded(child: Text('Clasificación', style: style)),
          Expanded(child: Text('Acciones', style: style)),
        ],
      ),
    );
  }

  Widget _cell(String text) {
    return Expanded(child: Text(text, style: const TextStyle(fontSize: 13)));
  }

  // ─────────────────────────────────────────
  // MODO MÓVIL
  // ─────────────────────────────────────────

  Widget _buildEmptyStateMobile() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, size: 80, color: Colors.black87),
          SizedBox(height: 16),
          Text(
            'NO SE HA AGREGADO NINGÚN PRODUCTO\nAL INVENTARIO',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: _productos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = _productos[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Text('#${p['id']}', style: const TextStyle(color: _headerColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(p['producto']!, style: const TextStyle(color: _headerColor, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: _headerColor, borderRadius: BorderRadius.circular(6)),
                      child: Text(p['clasificacion']!, style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _cardRow('Stock', p['stock']!),
                    _cardRow('Precio compra', p['compra']!),
                    _cardRow('Precio venta', p['venta']!),
                    _cardRow('Proveedor', p['proveedor']!),
                    _cardRow('Descripción', p['descripcion']!),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _accionBtnMobile('Editar', Icons.edit, Colors.blue, () => mostrarModalEditarProducto(context)),
                        _accionBtnMobile('Agregar Stock', Icons.add, Colors.green, () => mostrarModalEntradaStock(context)),
                        _accionBtnMobile('Salida Stock', Icons.remove, Colors.orange, () => mostrarModalSalidaStock(context)),
                        _accionBtnMobile('Eliminar', Icons.delete, Colors.red, () {}),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _accionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return _HoverButton(
      onTap: onTap,
      color: color,
      child: (isHovered) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isHovered ? color.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _accionBtnMobile(String label, IconData icon, Color color, VoidCallback onTap) {
    return _HoverButton(
      onTap: onTap,
      color: color,
      child: (isHovered) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isHovered ? color.withValues(alpha: 0.22) : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isHovered ? color : color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// BOTÓN AGREGAR
// ─────────────────────────────────────────

class _AgregarButton extends StatefulWidget {
  final bool isWide;
  final VoidCallback onTap;

  const _AgregarButton({required this.isWide, required this.onTap});

  @override
  State<_AgregarButton> createState() => _AgregarButtonState();
}

class _AgregarButtonState extends State<_AgregarButton> {
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
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.isWide ? null : double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: BoxDecoration(
            color: _hovered ? _hover : _base,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _hovered
                ? [BoxShadow(color: _base.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))]
                : [],
          ),
          child: const Text(
            'Agregar producto',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Itim'),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// HOVER BUTTON
// ─────────────────────────────────────────

class _HoverButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color color;
  final Widget Function(bool isHovered) child;

  const _HoverButton({required this.onTap, required this.color, required this.child});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: widget.child(_hovered),
        ),
      ),
    );
  }
}