import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/pdf_data.dart';

class PdfDatasource {
  Future<Uint8List> generarPdf(FacturaPdfInput input) async {
    final pdf = pw.Document();

    Uint8List? logoBytes;
    try {
      final logoFile = File('../frontend/assets/logo_taller.png');
      if (await logoFile.exists()) {
        logoBytes = await logoFile.readAsBytes();
      } else {
        print('Logo no encontrado en: ${logoFile.path}');
      }
    } catch (e) {
      print('Error cargando logo: $e');
      logoBytes = null;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          try {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(input.pdfData, logoBytes),
                pw.SizedBox(height: 20),
                _buildClienteVehiculoInfo(input.pdfData),
                pw.SizedBox(height: 20),
                _buildItemsTable(input.pdfData.items),
                pw.SizedBox(height: 20),
                _buildTotales(input.pdfData),
              ],
            );
          } catch (e) {
            print('Error en build page: $e');
            rethrow;
          }
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(PdfData data, Uint8List? logoBytes) {
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
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                (data.tipoFactura ?? 'Consumidor Final').toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'N° ${data.numeroFactura ?? '000000'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                _formatearFecha(data.fecha),
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildClienteVehiculoInfo(PdfData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Cliente:',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.Text(
                      data.nombreCliente,
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (data.rtnCliente != null && data.rtnCliente!.isNotEmpty)
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RTN:',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        data.rtnCliente!,
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              if (data.nrcCliente != null)
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'NRC:',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        '${data.nrcCliente}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (data.telefonoCliente != null || data.emailCliente != null)
            pw.SizedBox(height: 8),
          if (data.telefonoCliente != null)
            pw.Text(
              'Tel: ${data.telefonoCliente}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          if (data.emailCliente != null)
            pw.Text(
              'Email: ${data.emailCliente}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          if (_hasVehiculoData(data))
            pw.SizedBox(height: 8),
          if (_hasVehiculoData(data))
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    'Vehículo: ',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    '${data.marcaVehiculo ?? ''} ${data.modeloVehiculo ?? ''} (${data.anioVehiculo ?? ''})',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Text(
                    'Placa: ',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    data.placaVehiculo ?? 'N/A',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _hasVehiculoData(PdfData data) {
    return data.marcaVehiculo != null ||
        data.modeloVehiculo != null ||
        data.placaVehiculo != null ||
        data.anioVehiculo != null;
  }

  pw.Widget _buildItemsTable(List<ItemPdfData> items) {
    final rows = <pw.TableRow>[];
    rows.add(pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.red),
      children: [
        _tableHeader('CANT.'),
        _tableHeader('DESCRIPCION'),
        _tableHeader('PRECIO'),
        _tableHeader('TOTAL'),
      ],
    ));
    for (final item in items) {
      rows.add(pw.TableRow(
        children: [
          _tableCell('${item.cantidad}'),
          _tableCell('${item.nombreProducto} (${item.tipoProducto})'),
          _tableCell('\$${item.precioUnitario.toStringAsFixed(2)}'),
          _tableCell('\$${item.subtotal.toStringAsFixed(2)}'),
        ],
      ));
    }
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: rows,
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

  pw.Widget _buildTotales(PdfData data) {
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
                pw.Text(
                  '\$${data.subtotal.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
            if (data.descuentoPorcentaje > 0)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Descuento (${data.descuentoPorcentaje.toStringAsFixed(1)}%):',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700),
                  ),
                  pw.Text(
                    '-\$${data.descuento.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700),
                  ),
                ],
              )
            else if (data.descuento > 0)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Descuento:',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700),
                  ),
                  pw.Text(
                    '-\$${data.descuento.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.green700),
                  ),
                ],
              ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('IVA (13%):', style: const pw.TextStyle(fontSize: 10)),
                pw.Text(
                  '\$${data.iva.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
            pw.Divider(color: PdfColors.red, thickness: 1),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL:',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '\$${data.total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}

class FacturaPdfInput {
  final PdfData pdfData;

  FacturaPdfInput(this.pdfData);
}