import 'dart:async';
import 'dart:convert';
import '../../domain/entities/factura_pdf.dart';
import '../../domain/repositories/factura_pdf_repository.dart';

class FacturaPdfController {
  final FacturaPdfRepository _repository;

  final StreamController<FacturaPdf?> _facturaPdfController = StreamController<FacturaPdf?>.broadcast();
  final List<StreamSubscription> _suscripciones = [];

  bool _estaObteniendo = false;

  FacturaPdfController({
    required FacturaPdfRepository repository,
  }) : _repository = repository;

  Stream<FacturaPdf?> get facturaPdfStream => _facturaPdfController.stream;

  Future<String> obtenerFacturaPdf(int idFactura) async {
    if (_estaObteniendo) {
      return _respuestaError('Ya se esta procesando una solicitud');
    }

    _estaObteniendo = true;

    try {
      final facturaPdf = await _repository.obtenerFacturaParaPdf(idFactura);

      _facturaPdfController.add(facturaPdf);

      if (facturaPdf == null) {
        return _respuestaError('Factura no encontrada');
      }

      return _respuestaExitosa(_mapFacturaPdf(facturaPdf));
    } catch (e) {
      return _respuestaError('Error al obtener datos de factura: $e');
    } finally {
      _estaObteniendo = false;
    }
  }

  Map<String, dynamic> _mapFacturaPdf(FacturaPdf factura) {
    return {
      'id': factura.id,
      'numero_factura': factura.numeroFactura,
      'fecha': factura.fecha.toIso8601String(),
      'tipo_factura': factura.tipoFactura,
      'nombre_cliente': factura.nombreCliente,
      'nit_cliente': factura.nitCliente,
      'rtn_cliente': factura.rtnCliente,
      'telefono_cliente': factura.telefonoCliente,
      'vehiculo_info': factura.vehiculoInfo,
      'subtotal': factura.subtotal,
      'descuento_porcentaje': factura.descuentoPorcentaje,
      'descuento': factura.descuento,
      'iva': factura.iva,
      'total': factura.total,
      'nombre_oferta': factura.nombreOferta,
      'items': factura.detalles.map((d) => {
        'cantidad': d.cantidad,
        'nombre_producto': d.nombreProducto,
        'tipo_producto': d.tipoProducto,
        'descripcion': d.descripcion,
        'sku': d.sku,
        'precio_unitario': d.precioUnitario,
        'subtotal': d.subtotal,
      }).toList(),
    };
  }

  String _respuestaExitosa(dynamic data) {
    return json.encode({
      'success': true,
      'data': data,
    });
  }

  String _respuestaError(String mensaje) {
    return json.encode({
      'success': false,
      'message': mensaje,
    });
  }

  void dispose() {
    for (final suscripcion in _suscripciones) {
      suscripcion.cancel();
    }
    _suscripciones.clear();
    _facturaPdfController.close();
  }
}