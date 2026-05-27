import 'dart:typed_data';
import '../../domain/entities/pdf_data.dart';
import '../../domain/entities/factura.dart';
import '../../domain/entities/detalle_factura.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../../domain/usecases/generar_factura_pdf.dart';
import '../../data/datasources/supabase_datasource.dart';

class PdfController {
  final GenerarFacturaPdf generarFacturaPdf;
  final SupabaseDataSource supabaseDataSource;
  final ClienteRepository clienteRepository;

  PdfController({
    required this.generarFacturaPdf,
    required this.supabaseDataSource,
    required this.clienteRepository,
  });

  Stream<Uint8List> generarPdfPorId(int idFactura) async* {
    final facturaData = await _obtenerFacturaConDetalles(idFactura);

    if (facturaData == null) {
      throw Exception('Factura no encontrada con ID: $idFactura');
    }

    final pdfData = await _mapearFacturaAPdfData(facturaData);

    yield* generarFacturaPdf(pdfData);
  }

  Future<Map<String, dynamic>?> _obtenerFacturaConDetalles(int idFactura) async {
    try {
      final facturaResult = await supabaseDataSource.select(
        'facturacion',
        filtros: 'id=eq.$idFactura',
      );

      if (facturaResult.isEmpty) return null;
      final facturaMap = Map<String, dynamic>.from(facturaResult.first);

      final detallesResult = await supabaseDataSource.select(
        'detalles_factura',
        filtros: 'id_factura=eq.$idFactura',
      );

      facturaMap['detalles'] = detallesResult;

      return facturaMap;
    } catch (e) {
      throw Exception('Error al obtener factura: $e');
    }
  }

  Future<PdfData> _mapearFacturaAPdfData(Map<String, dynamic> facturaMap) async {
    final factura = Factura.fromJson(facturaMap);
    final detalles = facturaMap['detalles'] != null
        ? (facturaMap['detalles'] as List)
            .map((d) => DetalleFactura.fromJson(Map<String, dynamic>.from(d)))
            .toList()
        : <DetalleFactura>[];

    final numeroFactura = 'FAC-${factura.id?.toString().padLeft(6, '0') ?? '000000'}';

    String nombreCliente = 'Consumidor Final';
    String? rtnCliente;
    int? nrcCliente;
    String? telefonoCliente;
    String? emailCliente;

    if (factura.id_cliente != null) {
      final cliente = await clienteRepository.obtenerClientePorId(factura.id_cliente!);
      if (cliente != null) {
        nombreCliente = cliente.nombre;
        rtnCliente = cliente.rtn.isNotEmpty ? cliente.rtn : null;
        telefonoCliente = cliente.telefono;
        emailCliente = cliente.correo;
      }
    }

    return PdfData.fromFactura(
      idFactura: factura.id ?? 0,
      numeroFactura: numeroFactura,
      fecha: factura.fecha,
      tipoFactura: factura.tipo_factura.valor,
      nombreCliente: nombreCliente,
      rtnCliente: rtnCliente,
      nrcCliente: nrcCliente,
      telefonoCliente: telefonoCliente,
      emailCliente: emailCliente,
      marcaVehiculo: factura.marca_vehiculo,
      modeloVehiculo: factura.modelo_vehiculo,
      placaVehiculo: factura.placa_vehiculo,
      anioVehiculo: factura.anio_vehiculo,
      itemsData: detalles.map((d) => d.toJson()).toList(),
      subtotal: factura.subtotal,
      descuentoPorcentaje: factura.descuentoPorcentaje,
      descuento: factura.descuento,
      iva: factura.iva,
      total: factura.total,
    );
  }
}