import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FacturaPdfService {
  Future<Uint8List> generarFacturaPdfBytes(Map<String, dynamic> facturaData) async {
    final pdf = pw.Document();

    final nombreCliente = facturaData['nombre_cliente'] as String? ?? 'N/A';
    final nitCliente = facturaData['nit_cliente'] as String?;
    final rtnCliente = facturaData['rtn_cliente'] as String?;
    final telefonoCliente = facturaData['telefono_cliente'] as String?;
    final vehiculoInfo = facturaData['vehiculo_info'] as String?;
    final tipoFactura = facturaData['tipo_factura'] as String? ?? 'Consumidor Final';
    final numeroFactura = facturaData['numero_factura'] as String? ?? 'N/A';
    final fecha = _formatearFecha(facturaData['fecha'] as String? ?? DateTime.now().toIso8601String());

    final itemsRaw = facturaData['items'] as List? ?? [];
    final subtotal = (facturaData['subtotal'] as num?)?.toDouble() ?? 0.0;
    final descuentoPorcentaje = (facturaData['descuento_porcentaje'] as num?)?.toDouble() ?? 0.0;
    final descuento = (facturaData['descuento'] as num?)?.toDouble() ?? 0.0;
    final iva = (facturaData['iva'] as num?)?.toDouble() ?? 0.0;
    final total = (facturaData['total'] as num?)?.toDouble() ?? 0.0;

    final logoBytes = await _obtenerLogoBytes();
    final logoImage = logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _construirEncabezado(logoImage, tipoFactura, numeroFactura, fecha),
        footer: (context) => _construirPiePagina(context),
        build: (context) => [
          _construirInfoCliente(nombreCliente, nitCliente, rtnCliente, telefonoCliente, vehiculoInfo),
          pw.SizedBox(height: 16),
          pw.SizedBox(height: 20),
          _construirTablaItems(itemsRaw),
          pw.SizedBox(height: 24),
          _construirTotales(subtotal, descuentoPorcentaje, descuento, iva, total),
        ],
      ),
    );

    return pdf.save();
  }

  Future<Uint8List?> _obtenerLogoBytes() async {
    try {
      final byteData = await rootBundle.load('assets/logo_taller.png');
      return byteData.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  pw.Widget _construirEncabezado(pw.MemoryImage? logoImage, String tipoFactura, String numeroFactura, String fecha) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.red, width: 3),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (logoImage != null)
            pw.Container(
              width: 80,
              height: 80,
              child: pw.Image(logoImage, fit: pw.BoxFit.contain),
            )
          else
            pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                color: PdfColors.red,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text(
                  'TR',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'TALLER RODRIGUEZ',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Text(
                      tipoFactura.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red,
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Text(
                      'N° $numeroFactura',
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'FECHA',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
              pw.Text(
                fecha,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _construirInfoCliente(
    String nombreCliente,
    String? nitCliente,
    String? rtnCliente,
    String? telefonoCliente,
    String? vehiculoInfo,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL CLIENTE',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Cliente:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    pw.Text(nombreCliente, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    if (telefonoCliente != null) ...[
                      pw.SizedBox(height: 4),
                      pw.Text('Tel: $telefonoCliente', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (nitCliente != null) ...[
                      pw.Text('NIT:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                      pw.Text(nitCliente, style: const pw.TextStyle(fontSize: 10)),
                    ],
                    if (rtnCliente != null) ...[
                      pw.SizedBox(height: 4),
                      pw.Text('RTN:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                      pw.Text(rtnCliente, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ],
                ),
              ),
              if (vehiculoInfo != null)
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Vehículo:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                      pw.Text(vehiculoInfo, style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _construirInfoOferta(double descuentoPorcentaje) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        border: pw.Border.all(color: PdfColors.green700, width: 1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        children: [
          pw.Icon(pw.IconData(0xe8e5), color: PdfColors.green700, size: 16),
          pw.SizedBox(width: 8),
          pw.Text(
            'Descuento aplicado: ${descuentoPorcentaje.toStringAsFixed(1)}%',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
          ),
        ],
      ),
    );
  }

  pw.Widget _construirTablaItems(List itemsRaw) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.red),
          children: [
            _celdaEncabezado('DESCRIPCIÓN'),
            _celdaEncabezado('CANT.', center: true),
            _celdaEncabezado('PRECIO', center: true),
            _celdaEncabezado('SUBTOTAL', center: true),
          ],
        ),
        ...itemsRaw.map((item) {
          final itemMap = item as Map<String, dynamic>;
          final cantidad = itemMap['cantidad'] as int? ?? 1;
          final precio = (itemMap['precio_unitario'] as num?)?.toDouble() ?? 0.0;
          final itemTotal = cantidad * precio;
          final nombre = itemMap['nombre_producto']?.toString() ?? '';
          final tipoProducto = itemMap['tipo_producto']?.toString() ?? '';
          final descripcion = itemMap['descripcion']?.toString();

          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(nombre, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    if (descripcion != null && descripcion.isNotEmpty)
                      pw.Text(descripcion, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    pw.Text(
                      tipoProducto.toUpperCase(),
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
                    ),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  cantidad.toString(),
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '\$${precio.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '\$${itemTotal.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _celdaEncabezado(String texto, {bool center = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  pw.Widget _construirTotales(double subtotal, double descuentoPorcentaje, double descuento, double iva, double total) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey50,
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 11)),
                pw.Text('\$${subtotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
            if (descuentoPorcentaje > 0) ...[
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Descuento (${descuentoPorcentaje.toStringAsFixed(1)}%):', style: const pw.TextStyle(fontSize: 11, color: PdfColors.green700)),
                  pw.Text('-\$${descuento.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 11, color: PdfColors.green700)),
                ],
              ),
            ],
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('IVA (13%):', style: const pw.TextStyle(fontSize: 11)),
                pw.Text('\$${iva.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL A PAGAR:',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red800),
                ),
                pw.Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red800),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _construirPiePagina(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Taller Rodriguez - Todos los derechos reservados',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(String isoFecha) {
    try {
      final fecha = DateTime.parse(isoFecha);
      final hora = fecha.hour.toString().padLeft(2, '0');
      final minutos = fecha.minute.toString().padLeft(2, '0');
      return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} $hora:$minutos';
    } catch (e) {
      return isoFecha;
    }
  }
}