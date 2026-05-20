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
        return 'Crédito Fiscal';
      case TipoFactura.consumidorFinal:
        return 'Consumidor Final';
      case TipoFactura.notaCredito:
        return 'Nota de Crédito';
    }
  }

  static TipoFactura fromString(String value) {
    switch (value.toLowerCase()) {
      case 'crédito fiscal':
      case 'credito fiscal':
        return TipoFactura.creditoFiscal;
      case 'consumidor final':
        return TipoFactura.consumidorFinal;
      case 'nota de crédito':
      case 'nota credito':
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
  final double total;
  final int? id_cliente;
  final int? id_vehiculo;
  final int? id_oferta;
  final int? id_caja;
  final List<DetalleFactura> detalles;

  const Factura({
    this.id,
    required this.fecha,
    required this.tipo_factura,
    required this.subtotal,
    required this.iva,
    required this.descuento,
    required this.total,
    this.id_cliente,
    this.id_vehiculo,
    this.id_oferta,
    this.id_caja,
    this.detalles = const [],
  });

  factory Factura.crear({
    required DateTime fecha,
    required TipoFactura tipo_factura,
    required List<DetalleFactura> detalles,
    double descuentoPorcentaje = 0,
    int? id_cliente,
    int? id_vehiculo,
    int? id_oferta,
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
      total: total,
      id_cliente: id_cliente,
      id_vehiculo: id_vehiculo,
      id_oferta: id_oferta,
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
      total: (json['total'] as num?)?.toDouble() ?? 0,
      id_cliente: json['id_cliente'] as int?,
      id_vehiculo: json['id_vehiculo'] as int?,
      id_oferta: json['id_oferta'] as int?,
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
      'descuento': descuento,
      'total': total,
      'id_cliente': id_cliente,
      'id_vehiculo': id_vehiculo,
      'id_oferta': id_oferta,
      'id_caja': id_caja,
    };
  }

  @override
  List<Object?> get props => [id, fecha, tipo_factura, subtotal, iva, descuento, total, id_cliente, id_vehiculo, id_oferta, id_caja, detalles];
}