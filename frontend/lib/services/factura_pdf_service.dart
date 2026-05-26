import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;

class FacturaPdfService {
  Future<File> generarFacturaPdf(Map<String, dynamic> facturaData) async {
    final pdf = pw.Document();

    final nombreCliente = facturaData['cliente']?['nombre'] ?? 'N/A';
    final rtnCliente = facturaData['cliente']?['rtn'] ?? '';
    final tipoFactura = facturaData['tipo_factura'] ?? 'Consumidor Final';
    final numeroFactura = facturaData['numero_factura'] ?? facturaData['id']?.toString() ?? 'N/A';
    final fecha = _formatearFecha(facturaData['fecha'] ?? DateTime.now().toIso8601String());
    
    final items = (facturaData['items'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    final subtotal = (facturaData['subtotal'] as num?)?.toDouble() ?? 0.0;
    final descuentoPorcentaje = (facturaData['descuento_porcentaje'] as num?)?.toDouble() ?? 0.0;
    final descuento = (facturaData['descuento'] as num?)?.toDouble() ?? 0.0;
    final iva = (facturaData['iva'] as num?)?.toDouble() ?? 0.0;
    final total = (facturaData['total'] as num?)?.toDouble() ?? 0.0;

    Uint8List? logoBytes;
    try {
      final ByteData data = await rootBundle.load('assets/logo_taller.png');
      logoBytes = data.buffer.asUint8List();
    } catch (e) {
      logoBytes = null;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(tipoFactura, numeroFactura, fecha, logoBytes),
              pw.SizedBox(height: 20),
              _buildClienteInfo(nombreCliente, rtnCliente),
              pw.SizedBox(height: 20),
              _buildItemsTable(items),
              pw.SizedBox(height: 20),
              _buildTotales(subtotal, descuentoPorcentaje, descuento, iva, total),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    
    if (kIsWeb) {
      return _downloadWeb(bytes, 'factura_$numeroFactura.pdf');
    } else {
      final dir = Directory.systemTemp;
      final file = File('${dir.path}/factura_$numeroFactura.pdf');
      await file.writeAsBytes(bytes);
      return file;
    }
  }

  File _downloadWeb(List<int> bytes, String filename) {
    return File('/tmp/$filename');
  }

  pw.Widget _buildHeader(String tipoFactura, String numeroFactura, String fecha, Uint8List? logoBytes) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.red, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              if (logoBytes != null)
                pw.ClipRRect(
                  horizontalRadius: 8,
                  verticalRadius: 8,
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    width: 50,
                    height: 50,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              if (logoBytes != null) pw.SizedBox(width: 12),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'TALLER RODRIGUEZ',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red),
                  ),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(tipoFactura.toUpperCase(), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('N° $numeroFactura', style: const pw.TextStyle(fontSize: 12)),
              pw.Text(fecha, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildClienteInfo(String nombre, String rtn) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Cliente:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                pw.Text(nombre, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('RTN:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                pw.Text(rtn.isNotEmpty ? rtn : 'N/A', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildItemsTable(List<Map<String, dynamic>> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.red),
          children: [
            _tableHeader('CANT.'),
            _tableHeader('DESCRIPCION'),
            _tableHeader('PRECIO'),
            _tableHeader('TOTAL'),
          ],
        ),
        ...items.map((item) => pw.TableRow(
          children: [
            _tableCell('${item['cantidad']}'),
            _tableCell(item['nombre_producto']?.toString() ?? item['nombre']?.toString() ?? ''),
            _tableCell('\$${(item['precio_unitario'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
            _tableCell('\$${((item['cantidad'] as int) * ((item['precio_unitario'] as num?)?.toDouble() ?? 0.0)).toStringAsFixed(2)}'),
          ],
        )),
      ],
    );
  }

  pw.Widget _tableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _tableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  pw.Widget _buildTotales(double subtotal, double descuentoPorcentaje, double descuento, double iva, double total) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 200,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('\$${subtotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            if (descuentoPorcentaje > 0)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Descuento (${descuentoPorcentaje.toStringAsFixed(1)}%):', style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700)),
                  pw.Text('-\$${descuento.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700)),
                ],
              )
            else if (descuento > 0)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Descuento:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700)),
                  pw.Text('-\$${descuento.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700)),
                ],
              ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('IVA (13%):', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('\$${iva.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.Divider(color: PdfColors.red, thickness: 1),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text('\$${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _totalRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isBold ? 12 : 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isBold ? 14 : 10,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isBold ? PdfColors.red : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(String isoFecha) {
    try {
      final fecha = DateTime.parse(isoFecha);
      return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    } catch (e) {
      return isoFecha;
    }
  }
}