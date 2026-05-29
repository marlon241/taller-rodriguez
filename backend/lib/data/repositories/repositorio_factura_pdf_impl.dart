import '../../domain/entities/factura_pdf.dart';
import '../../domain/repositories/factura_pdf_repository.dart';
import '../datasources/supabase_datasource.dart';

class FacturaPdfRepositoryImpl implements FacturaPdfRepository {
  final SupabaseDataSource _dataSource;

  FacturaPdfRepositoryImpl(this._dataSource);

  @override
  Future<FacturaPdf?> obtenerFacturaParaPdf(int idFactura) async {
    try {
      final datosFactura = await _dataSource.select(
        'facturacion',
        filtros: 'id=eq.$idFactura',
      );

      if (datosFactura.isEmpty) return null;

      final factura = datosFactura.first;
      final detalles = await _obtenerDetallesFactura(idFactura);

      return FacturaPdf(
        id: factura['id'] as int,
        numeroFactura: 'FAC-${factura['id']}'.padLeft(10, '0'),
        fecha: DateTime.parse(factura['fecha'] as String),
        tipoFactura: factura['tipo_factura'] as String,
        nombreCliente: factura['nombre_cliente'] as String? ?? '',
        nitCliente: factura['nit_cliente'] as String?,
        rtnCliente: factura['rtn_cliente'] as String?,
        telefonoCliente: factura['telefono_cliente'] as String?,
        vehiculoInfo: _formatearVehiculo(factura),
        subtotal: (factura['subtotal'] as num).toDouble(),
        descuentoPorcentaje: (factura['descuento_porcentaje'] as num?)?.toDouble() ?? 0.0,
        descuento: (factura['descuento'] as num?)?.toDouble() ?? 0.0,
        iva: (factura['iva'] as num).toDouble(),
        total: (factura['total'] as num).toDouble(),
        detalles: detalles,
        nombreOferta: factura['nombre_oferta'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<DetallePdf>> _obtenerDetallesFactura(int idFactura) async {
    try {
      final datos = await _dataSource.select(
        'detalles_factura',
        filtros: 'id_factura=eq.$idFactura',
      );

      return datos.map((json) => DetallePdf(
        cantidad: json['cantidad'] as int,
        nombreProducto: json['nombre_producto'] as String,
        tipoProducto: json['tipo_producto'] as String,
        descripcion: json['descripcion'] as String?,
        sku: json['sku'] as String?,
        precioUnitario: (json['precio_unitario'] as num).toDouble(),
        subtotal: (json['subtotal'] as num).toDouble(),
      )).toList();
    } catch (e) {
      return [];
    }
  }

  String? _formatearVehiculo(Map<String, dynamic> factura) {
    final marca = factura['marca_vehiculo'] as String?;
    final modelo = factura['modelo_vehiculo'] as String?;
    final anio = factura['anio_vehiculo'] as int?;
    final placa = factura['placa_vehiculo'] as String?;

    if (marca == null && modelo == null && anio == null && placa == null) {
      return null;
    }

    final partes = <String>[];
    if (marca != null) partes.add(marca);
    if (modelo != null) partes.add(modelo);
    if (anio != null) partes.add(anio.toString());
    if (placa != null) partes.add('Placa: $placa');

    return partes.join(' ');
  }
}
