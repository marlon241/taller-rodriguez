import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';

class HistorialTurnosPage extends StatefulWidget {
  const HistorialTurnosPage({super.key});

  @override
  State<HistorialTurnosPage> createState() => _HistorialTurnosPageState();
}

class _HistorialTurnosPageState extends State<HistorialTurnosPage> {
  static const Color _headerColor = Color(0xFFA61B1B);

  final List<Map<String, String>> _turnos = [
    {
      'fecha': '01/05/2025',
      'turno': 'T-001',
      'responsable': 'Javier Ruano',
      'inicial': '\$100.00',
      'ingresos': '\$500.00',
      'egresos': '\$50.00',
      'final': '\$550.00',
      'horaInicio': '08:00',
      'horaCierre': '17:00',
    },
    {
      'fecha': '02/05/2025',
      'turno': 'T-002',
      'responsable': 'María López',
      'inicial': '\$200.00',
      'ingresos': '\$750.00',
      'egresos': '\$80.00',
      'final': '\$870.00',
      'horaInicio': '07:00',
      'horaCierre': '16:00',
    },
    {
      'fecha': '03/05/2025',
      'turno': 'T-003',
      'responsable': 'Carlos Pérez',
      'inicial': '\$150.00',
      'ingresos': '\$620.00',
      'egresos': '\$30.00',
      'final': '\$740.00',
      'horaInicio': '09:00',
      'horaCierre': '18:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      drawer: isWide ? null : const SidebarDrawerContent(),
      appBar: isWide ? null : AppBar(title: const Text('Historial de turnos')),
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
                        'Historial de turnos',
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
                      child: _turnos.isEmpty
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
          final double tableWidth = constraints.maxWidth > 860 ? constraints.maxWidth : 860;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              height: 400,
              child: Column(
                children: [
                  _buildTableHeader(),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 80, color: Colors.black26),
                        SizedBox(height: 16),
                        Text(
                          'NO HAY TURNOS REGISTRADOS',
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
          final double tableWidth = constraints.maxWidth > 860 ? constraints.maxWidth : 860;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _buildTableHeader(),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _turnos.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final t = _turnos[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            SizedBox(width: 90,  child: Text(t['fecha']!,       style: const TextStyle(fontSize: 13))),
                            SizedBox(width: 80,  child: Text(t['turno']!,       style: const TextStyle(fontSize: 13))),
                            SizedBox(width: 130, child: Text(t['responsable']!, style: const TextStyle(fontSize: 13))),
                            SizedBox(width: 80,  child: Text(t['inicial']!,     style: const TextStyle(fontSize: 13))),
                            SizedBox(width: 90,  child: Text(t['ingresos']!,    style: const TextStyle(fontSize: 13))),
                            SizedBox(width: 90,  child: Text(t['egresos']!,     style: const TextStyle(fontSize: 13))),
                            SizedBox(width: 80,  child: Text(t['final']!,       style: const TextStyle(fontSize: 13))),
                            SizedBox(width: 100, child: Text(t['horaInicio']!,  style: const TextStyle(fontSize: 13))),
                            Expanded(            child: Text(t['horaCierre']!,  style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
          SizedBox(width: 90,  child: Text('FECHA',       style: style)),
          SizedBox(width: 80,  child: Text('TURNO',       style: style)),
          SizedBox(width: 130, child: Text('RESPONSABLE', style: style)),
          SizedBox(width: 80,  child: Text('INICIAL',     style: style)),
          SizedBox(width: 90,  child: Text('INGRESOS',    style: style)),
          SizedBox(width: 90,  child: Text('EGRESOS',     style: style)),
          SizedBox(width: 80,  child: Text('FINAL',       style: style)),
          SizedBox(width: 100, child: Text('HORA INICIO', style: style)),
          Expanded(            child: Text('HORA CIERRE', style: style)),
        ],
      ),
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
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 4))]
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