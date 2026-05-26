import 'package:equatable/equatable.dart';
import 'detalle_factura.dart';

enum TipoFactura {
  creditoFiscal,
  consumidorFinal,
  notaCredito,
}

extension TipoFacturaExtension on TipoFactura {
  String get valor {
    switch (this) {
      case TipoFactura.creditoFiscal:
        return 'Credito Fiscal';
      case TipoFactura.consumidorFinal:
        return 'Consumidor Final';
      case TipoFactura.notaCredito:
        return 'Nota de Credito';
    }
  }

  static TipoFactura fromString(String value) {
    final normalized = value.toLowerCase().replaceAll('_', ' ').trim();
    switch (normalized) {
      case 'credito fiscal':
      case 'crédito fiscal':
        return TipoFactura.creditoFiscal;
      case 'consumidor final':
        return TipoFactura.consumidorFinal;
      case 'nota de credito':
      case 'nota crédito':
        return TipoFactura.notaCredito;
      default:
        return TipoFactura.consumidorFinal;
    }
  }
}

class Factura extends Equatable {
  final int? id;
  final DateTime fecha;
  final TipoFactura tipo_factura;
  final double subtotal;
  final double iva;
  final double descuento;
  final double descuentoPorcentaje;
  final double total;
  final int? id_cliente;
  final String? nombre_cliente;
  final String? telefono_cliente;
  final String? dui_cliente;
  final String? correo_cliente;
  final int? id_vehiculo;
  final String? modelo_vehiculo;
  final String? marca_vehiculo;
  final String? placa_vehiculo;
  final int? anio_vehiculo;
  final int? id_oferta;
  final String? nombre_oferta;
  final double? porcentaje_oferta;
  final int? id_caja;
  final List<DetalleFactura> detalles;

  const Factura({
    this.id,
    required this.fecha,
    required this.tipo_factura,
    required this.subtotal,
    required this.iva,
    required this.descuento,
    this.descuentoPorcentaje = 0,
    required this.total,
    this.id_cliente,
    this.nombre_cliente,
    this.telefono_cliente,
    this.dui_cliente,
    this.correo_cliente,
    this.id_vehiculo,
    this.modelo_vehiculo,
    this.marca_vehiculo,
    this.placa_vehiculo,
    this.anio_vehiculo,
    this.id_oferta,
    this.nombre_oferta,
    this.porcentaje_oferta,
    this.id_caja,
    this.detalles = const [],
  });

  factory Factura.crear({
    required DateTime fecha,
    required TipoFactura tipo_factura,
    required List<DetalleFactura> detalles,
    double descuentoPorcentaje = 0,
    int? id_cliente,
    String? nombre_cliente,
    String? telefono_cliente,
    String? dui_cliente,
    String? correo_cliente,
    int? id_vehiculo,
    String? modelo_vehiculo,
    String? marca_vehiculo,
    String? placa_vehiculo,
    int? anio_vehiculo,
    int? id_oferta,
    String? nombre_oferta,
    double? porcentaje_oferta,
    int? id_caja,
  }) {
    final subtotal = detalles.fold<double>(0, (sum, detalle) => sum + detalle.subtotal);
    
    final descuento = subtotal * (descuentoPorcentaje / 100);
    final subtotalConDescuento = subtotal - descuento;
    
    final iva = subtotalConDescuento * 0.13;
    
    final total = subtotalConDescuento + iva;

    return Factura(
      fecha: fecha,
      tipo_factura: tipo_factura,
      subtotal: subtotal,
      iva: iva,
      descuento: descuento,
      descuentoPorcentaje: descuentoPorcentaje,
      total: total,
      id_cliente: id_cliente,
      nombre_cliente: nombre_cliente,
      telefono_cliente: telefono_cliente,
      dui_cliente: dui_cliente,
      correo_cliente: correo_cliente,
      id_vehiculo: id_vehiculo,
      modelo_vehiculo: modelo_vehiculo,
      marca_vehiculo: marca_vehiculo,
      placa_vehiculo: placa_vehiculo,
      anio_vehiculo: anio_vehiculo,
      id_oferta: id_oferta,
      nombre_oferta: nombre_oferta,
      porcentaje_oferta: porcentaje_oferta,
      id_caja: id_caja,
      detalles: detalles,
    );
  }

  factory Factura.fromJson(Map<String, dynamic> json) {
    return Factura(
      id: json['id'] as int?,
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now()
          : DateTime.now(),
      tipo_factura: TipoFacturaExtension.fromString(json['tipo_factura'] as String? ?? ''),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      iva: (json['iva'] as num?)?.toDouble() ?? 0,
      descuento: (json['descuento'] as num?)?.toDouble() ?? 0,
      descuentoPorcentaje: (json['descuento_porcentaje'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      id_cliente: json['id_cliente'] as int?,
      nombre_cliente: json['nombre_cliente'] as String?,
      telefono_cliente: json['telefono_cliente'] as String?,
      dui_cliente: json['dui_cliente'] as String?,
      correo_cliente: json['correo_cliente'] as String?,
      id_vehiculo: json['id_vehiculo'] as int?,
      modelo_vehiculo: json['modelo_vehiculo'] as String?,
      marca_vehiculo: json['marca_vehiculo'] as String?,
      placa_vehiculo: json['placa_vehiculo'] as String?,
      anio_vehiculo: json['anio_vehiculo'] as int?,
      id_oferta: json['id_oferta'] as int?,
      nombre_oferta: json['nombre_oferta'] as String?,
      porcentaje_oferta: (json['porcentaje_oferta'] as num?)?.toDouble(),
      id_caja: json['id_caja'] as int?,
      detalles: json['detalles'] != null
          ? (json['detalles'] as List).map((d) => DetalleFactura.fromJson(d)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fecha': fecha.toIso8601String(),
      'tipo_factura': tipo_factura.valor,
      'subtotal': subtotal,
      'iva': iva,
      'descuento_porcentaje': descuentoPorcentaje,
      'descuento': descuento,
      'total': total,
      'id_cliente': id_cliente,
      'nombre_cliente': nombre_cliente,
      'telefono_cliente': telefono_cliente,
      'dui_cliente': dui_cliente,
      'correo_cliente': correo_cliente,
      'id_vehiculo': id_vehiculo,
      'modelo_vehiculo': modelo_vehiculo,
      'marca_vehiculo': marca_vehiculo,
      'placa_vehiculo': placa_vehiculo,
      'anio_vehiculo': anio_vehiculo,
      'id_oferta': id_oferta,
      'nombre_oferta': nombre_oferta,
      'porcentaje_oferta': porcentaje_oferta,
      'id_caja': id_caja,
    };
  }

  @override
  List<Object?> get props => [id, fecha, tipo_factura, subtotal, iva, descuento, total, id_cliente, nombre_cliente, telefono_cliente, dui_cliente, correo_cliente, id_vehiculo, modelo_vehiculo, marca_vehiculo, placa_vehiculo, anio_vehiculo, id_oferta, nombre_oferta, porcentaje_oferta, id_caja, detalles];
}