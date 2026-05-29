import 'package:equatable/equatable.dart';

class FacturaPdf extends Equatable {
  final int id;
  final String numeroFactura;
  final DateTime fecha;
  final String tipoFactura;
  final String nombreCliente;
  final String? nitCliente;
  final String? rtnCliente;
  final String? telefonoCliente;
  final String? vehiculoInfo;
  final double subtotal;
  final double descuentoPorcentaje;
  final double descuento;
  final double iva;
  final double total;
  final List<DetallePdf> detalles;
  final String? nombreOferta;

  const FacturaPdf({
    required this.id,
    required this.numeroFactura,
    required this.fecha,
    required this.tipoFactura,
    required this.nombreCliente,
    this.nitCliente,
    this.rtnCliente,
    this.telefonoCliente,
    this.vehiculoInfo,
    required this.subtotal,
    required this.descuentoPorcentaje,
    required this.descuento,
    required this.iva,
    required this.total,
    required this.detalles,
    this.nombreOferta,
  });

  @override
  List<Object?> get props => [
        id,
        numeroFactura,
        fecha,
        tipoFactura,
        nombreCliente,
        nitCliente,
        rtnCliente,
        telefonoCliente,
        vehiculoInfo,
        subtotal,
        descuentoPorcentaje,
        descuento,
        iva,
        total,
        detalles,
        nombreOferta,
      ];
}

class DetallePdf extends Equatable {
  final int cantidad;
  final String nombreProducto;
  final String tipoProducto;
  final String? descripcion;
  final String? sku;
  final double precioUnitario;
  final double subtotal;

  const DetallePdf({
    required this.cantidad,
    required this.nombreProducto,
    required this.tipoProducto,
    this.descripcion,
    this.sku,
    required this.precioUnitario,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [
        cantidad,
        nombreProducto,
        tipoProducto,
        descripcion,
        sku,
        precioUnitario,
        subtotal,
      ];
}