import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';

class CajaPage extends StatefulWidget {
  const CajaPage({super.key});

  @override
  State<CajaPage> createState() => _CajaPageState();
}

class _CajaPageState extends State<CajaPage> {
  // ── Estado principal de la caja ──────────────────────────────────────────
  // Cambia este valor a `true` para simular caja abierta, `false` para cerrada.
  bool _cajaAbierta = false;

  // TODO (backend): traer estos valores desde la API
  final String _responsable = 'Nombre del empleado'; // reemplazar con dato real
  final String _efectivoActual = '\$100';             // reemplazar con dato real
  final String _fecha = '20/10/2025';                 // reemplazar con DateTime.now()

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      appBar: isWide ? null : AppBar(title: const Text('Caja')),
      drawer: isWide ? null : const SidebarDrawerContent(),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: Center(
                child: _buildCajaCard(isWide),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TARJETA PRINCIPAL
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCajaCard(bool isWide) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: Container(
        width: double.infinity,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(),
            // Cuerpo con la información
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Estado de la caja:', _estadoWidget()),
                  const SizedBox(height: 16),
                  _buildInfoRow('Fecha:', Text(_fecha, style: _bodyStyle)),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Responsable:',
                    Text(
                      '($_responsable)', // TODO: quitar paréntesis cuando venga del backend
                      style: _bodyStyle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Efectivo actual:',
                    Text(
                      _efectivoActual, // TODO: formatear con intl cuando venga del backend
                      style: _bodyStyle,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botones — centrados con espacio uniforme en escritorio,
                  // columna estirada en móvil
                  isWide
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _CajaButton(
                              label: 'Abrir caja',
                              onTap: _abrirCaja,
                              width: 160,
                            ),
                            const SizedBox(width: 20),
                            _CajaButton(
                              label: 'Cerrar caja',
                              onTap: _cerrarCaja,
                              width: 160,
                            ),
                            const SizedBox(width: 20),
                            _CajaButton(
                              label: 'Historial de turnos',
                              onTap: _verHistorial,
                              width: 200,
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _CajaButton(label: 'Abrir caja', onTap: _abrirCaja),
                            const SizedBox(height: 12),
                            _CajaButton(label: 'Cerrar caja', onTap: _cerrarCaja),
                            const SizedBox(height: 12),
                            _CajaButton(
                                label: 'Historial de turnos',
                                onTap: _verHistorial),
                          ],
                        ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: const Text(
        'Caja del taller',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          fontFamily: 'Itim',
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(width: 8),
        value,
      ],
    );
  }

  /// Indicador de estado: punto de color + texto ABIERTA / CERRADA
  Widget _estadoWidget() {
    final color = _cajaAbierta ? Colors.green : Colors.red;
    final texto = _cajaAbierta ? 'ABIERTA' : 'CERRADA';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static const TextStyle _bodyStyle = TextStyle(
    fontSize: 16,
    color: Color(0xFF444444),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // ACCIONES
  // ─────────────────────────────────────────────────────────────────────────
  void _abrirCaja() {
    // TODO (backend): llamar al endpoint de apertura de caja
    setState(() => _cajaAbierta = true);
  }

  void _cerrarCaja() {
    // TODO (backend): llamar al endpoint de cierre de caja
    setState(() => _cajaAbierta = false);
  }

  void _verHistorial() {
    Navigator.pushNamed(context, '/historialTurnos');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTÓN ROJO CON HOVER — idéntico al patrón _AgregarButton de inventario
// ─────────────────────────────────────────────────────────────────────────────
class _CajaButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  // width opcional: en escritorio se pasa un valor fijo para igualar tamaños;
  // en móvil se omite y el botón se estira al ancho del Column.
  final double? width;

  const _CajaButton({required this.label, required this.onTap, this.width});

  @override
  State<_CajaButton> createState() => _CajaButtonState();
}

class _CajaButtonState extends State<_CajaButton> {
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
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
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
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Itim',
            ),
          ),
        ),
      ),
    );
  }
}