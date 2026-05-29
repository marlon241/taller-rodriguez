import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/factura_pdf_service.dart';

class DialogoDescargaFactura extends StatefulWidget {
  final Map<String, dynamic> facturaData;

  const DialogoDescargaFactura({
    super.key,
    required this.facturaData,
  });

  @override
  State<DialogoDescargaFactura> createState() => _DialogoDescargaFacturaState();
}

class _DialogoDescargaFacturaState extends State<DialogoDescargaFactura> {
  final FacturaPdfService _pdfService = FacturaPdfService();
  
  bool _generandoPdf = false;
  bool _pdfGenerado = false;
  Uint8List? _pdfBytes;
  String? _errorPdf;

  String get _numeroFactura => widget.facturaData['numero_factura'] as String? ?? 'N/A';
  
  double get _total => (widget.facturaData['total'] as num?)?.toDouble() ?? 0.0;
  
  String get _nombreCliente => widget.facturaData['nombre_cliente'] as String? ?? 'Consumidor Final';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconoEstado(),
              const SizedBox(height: 16),
              Text(
                _pdfGenerado ? 'PDF Listo' : 'Factura Generada',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Itim',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Factura #$_numeroFactura',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _nombreCliente,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total: \$${_total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_generandoPdf)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFFE53935)),
                    SizedBox(height: 12),
                    Text(
                      'Generando PDF...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              else if (_errorPdf != null)
                Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        _errorPdf!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              else if (_pdfGenerado && _pdfBytes != null)
                Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      'PDF generado exitosamente',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
              const SizedBox(height: 24),
              _buildBotones(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconoEstado() {
    if (_pdfGenerado) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          size: 48,
          color: Colors.green.shade700,
        ),
      );
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.description,
        size: 48,
        color: Colors.red.shade700,
      ),
    );
  }

  Widget _buildBotones() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _generandoPdf ? null : _generarYDescargarPdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              _pdfGenerado ? Icons.download : Icons.picture_as_pdf,
              color: Colors.white,
            ),
            label: Text(
              _pdfGenerado ? 'Descargar PDF' : 'Generar PDF',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Itim',
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _generandoPdf ? null : _cerrarDialogo,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: Text(
              'Cerrar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontFamily: 'Itim',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _generarYDescargarPdf() async {
    if (_pdfGenerado && _pdfBytes != null) {
      _descargarPdfWeb(_pdfBytes!, _numeroFactura);
      return;
    }

    setState(() {
      _generandoPdf = true;
      _errorPdf = null;
    });

    try {
      final bytes = await _pdfService.generarFacturaPdfBytes(widget.facturaData);
      
      setState(() {
        _pdfBytes = bytes;
        _pdfGenerado = true;
        _generandoPdf = false;
      });
      
      _descargarPdfWeb(bytes, _numeroFactura);
    } catch (e) {
      setState(() {
        _errorPdf = 'Error al generar PDF: $e';
        _generandoPdf = false;
      });
    }
  }

  void _descargarPdfWeb(Uint8List bytes, String numeroFactura) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'factura_$numeroFactura.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _cerrarDialogo() {
    Navigator.of(context).pop();
  }
}