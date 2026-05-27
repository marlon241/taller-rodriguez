import 'package:equatable/equatable.dart';

class PdfData extends Equatable {
  final int idFactura;
  final String numeroFactura;
  final DateTime fecha;
  final String tipoFactura;
  final String nombreCliente;
  final String? rtnCliente;
  final int? nrcCliente;
  final String? telefonoCliente;
  final String? direccionCliente;
  final String? emailCliente;
  final String? marcaVehiculo;
  final String? modeloVehiculo;
  final String? placaVehiculo;
  final int? anioVehiculo;
  final List<ItemPdfData> items;
  final double subtotal;
  final double descuentoPorcentaje;
  final double descuento;
  final double iva;
  final double total;

  const PdfData({
    required this.idFactura,
    required this.numeroFactura,
    required this.fecha,
    required this.tipoFactura,
    required this.nombreCliente,
    this.rtnCliente,
    this.nrcCliente,
    this.telefonoCliente,
    this.direccionCliente,
    this.emailCliente,
    this.marcaVehiculo,
    this.modeloVehiculo,
    this.placaVehiculo,
    this.anioVehiculo,
    required this.items,
    required this.subtotal,
    required this.descuentoPorcentaje,
    required this.descuento,
    required this.iva,
    required this.total,
  });

  factory PdfData.fromFactura({
    required int idFactura,
    required String numeroFactura,
    required DateTime fecha,
    required String tipoFactura,
    required String nombreCliente,
    String? rtnCliente,
    String? telefonoCliente,
    String? direccionCliente,
    String? emailCliente,
    String? marcaVehiculo,
    String? modeloVehiculo,
    String? placaVehiculo,
    int? anioVehiculo,
    required List<Map<String, dynamic>> itemsData,
    required double subtotal,
    required double descuentoPorcentaje,
    required double descuento,
    required double iva,
    required double total,
  }) {
    return PdfData(
      idFactura: idFactura,
      numeroFactura: numeroFactura,
      fecha: fecha,
      tipoFactura: tipoFactura,
      nombreCliente: nombreCliente,
      rtnCliente: rtnCliente,
      telefonoCliente: telefonoCliente,
      direccionCliente: direccionCliente,
      emailCliente: emailCliente,
      marcaVehiculo: marcaVehiculo,
      modeloVehiculo: modeloVehiculo,
      placaVehiculo: placaVehiculo,
      anioVehiculo: anioVehiculo,
      items: itemsData.map((item) => ItemPdfData.fromMap(item)).toList(),
      subtotal: subtotal,
      descuentoPorcentaje: descuentoPorcentaje,
      descuento: descuento,
      iva: iva,
      total: total,
    );
  }

  @override
  List<Object?> get props => [
        idFactura,
        numeroFactura,
        fecha,
        tipoFactura,
        nombreCliente,
        rtnCliente,
        nrcCliente,
        telefonoCliente,
        direccionCliente,
        emailCliente,
        marcaVehiculo,
        modeloVehiculo,
        placaVehiculo,
        anioVehiculo,
        items,
        subtotal,
        descuentoPorcentaje,
        descuento,
        iva,
        total,
      ];
}

class ItemPdfData extends Equatable {
  final String nombreProducto;
  final String tipoProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const ItemPdfData({
    required this.nombreProducto,
    required this.tipoProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory ItemPdfData.fromMap(Map<String, dynamic> map) {
    return ItemPdfData(
      nombreProducto: map['nombre_producto'] as String? ?? map['nombre'] as String? ?? '',
      tipoProducto: map['tipo_producto'] as String? ?? 'Producto',
      cantidad: map['cantidad'] as int? ?? 1,
      precioUnitario: (map['precio_unitario'] as num?)?.toDouble() ?? 0.0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [nombreProducto, tipoProducto, cantidad, precioUnitario, subtotal];
}