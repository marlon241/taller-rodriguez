import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';

class HistorialFacturasPage extends StatefulWidget {
  const HistorialFacturasPage({super.key});

  @override
  State<HistorialFacturasPage> createState() => _HistorialFacturasPageState();
}

class _HistorialFacturasPageState extends State<HistorialFacturasPage> {
  static const Color _headerColor = Color(0xFFA61B1B);

  final List<Map<String, String>> _facturas = [
    {
      'codigo': 'FAC-0001',
      'responsable': 'Javier Ruano',
      'totalVenta': '\$250.00',
      'fechaEmision': '01/05/2025',
    },
    {
      'codigo': 'FAC-0002',
      'responsable': 'María López',
      'totalVenta': '\$980.00',
      'fechaEmision': '02/05/2025',
    },
    {
      'codigo': 'FAC-0003',
      'responsable': 'Carlos Pérez',
      'totalVenta': '\$125.50',
      'fechaEmision': '03/05/2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      drawer: isWide ? null : const SidebarDrawerContent(),
      appBar: isWide ? null : AppBar(title: const Text('Historial de facturas')),
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
                        'Historial de facturas',
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
                    child: Container(
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
                      child: _facturas.isEmpty
                          ? _buildEmptyState()
                          : _buildTable(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _BotonVolver(
                        onPressed: () => Navigator.pushNamed(context, '/caja'),
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

  Widget _buildEmptyState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 1000;
          if (isWide) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: constraints.maxWidth,
                height: 400,
                child: Column(
                  children: [
                    _buildTableHeader(),
                    const Expanded(child: _EmptyContent()),
                  ],
                ),
              ),
            );
          }
          return const SizedBox(
            height: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_EmptyContent()],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTable() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth > 1000;
          if (isWide) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: constraints.maxWidth,
                child: _buildTableContent(isWide: true),
              ),
            );
          }
          return _buildTableContent(isWide: false);
        },
      ),
    );
  }

  Widget _buildTableContent({required bool isWide}) {
    return Column(
      children: [
        if (isWide) _buildTableHeader(),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _facturas.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final f = _facturas[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: isWide
                  ? Row(
                      children: [
                        SizedBox(width: 180, child: Text(f['codigo']!,       style: const TextStyle(fontSize: 13))),
                        SizedBox(width: 200, child: Text(f['responsable']!,  style: const TextStyle(fontSize: 13))),
                        SizedBox(width: 160, child: Text(f['totalVenta']!,   style: const TextStyle(fontSize: 13))),
                        SizedBox(width: 140, child: Text(f['fechaEmision']!, style: const TextStyle(fontSize: 13))),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _botonEditar(),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f['codigo']!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(f['responsable']!,
                            style: const TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f['totalVenta']!,
                                    style: const TextStyle(fontSize: 13)),
                                Text(f['fechaEmision']!,
                                    style: const TextStyle(fontSize: 12, color: Colors.black45)),
                              ],
                            ),
                            _botonEditar(),
                          ],
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
      color: _headerColor,
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 180, child: Text('CÓDIGO DE FACTURA', style: style)),
          SizedBox(width: 200, child: Text('RESPONSABLE',       style: style)),
          SizedBox(width: 160, child: Text('TOTAL DE VENTA',    style: style)),
          Expanded(            child: Text('FECHA DE EMISION',  style: style)),
        ],
      ),
    );
  }

  Widget _botonEditar() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC0392B),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Editar Factura',
        style: TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.receipt_long, size: 80, color: Colors.black26),
        SizedBox(height: 16),
        Text(
          'NO HAY FACTURAS REGISTRADAS',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _BotonVolver extends StatefulWidget {
  final VoidCallback onPressed;

  const _BotonVolver({required this.onPressed});

  @override
  State<_BotonVolver> createState() => _BotonVolverState();
}

class _BotonVolverState extends State<_BotonVolver> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFF9B1B1B) : const Color(0xFFC0392B),
          borderRadius: BorderRadius.circular(8),
          boxShadow: _hovered
              ? [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )]
              : [],
        ),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: Text(
              'Volver a caja',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Itim',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}