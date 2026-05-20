import 'package:equatable/equatable.dart';

enum TipoProducto {
  producto,
  servicio,
}

extension TipoProductoExtension on TipoProducto {
  String get valor {
    switch (this) {
      case TipoProducto.producto:
        return 'Producto';
      case TipoProducto.servicio:
        return 'Servicio';
    }
  }

  static TipoProducto fromString(String value) {
    switch (value.toLowerCase()) {
      case 'producto':
        return TipoProducto.producto;
      case 'servicio':
        return TipoProducto.servicio;
      default:
        return TipoProducto.producto;
    }
  }
}

class DetalleFactura extends Equatable {
  final int? id;
  final int? id_factura;
  final String id_producto_firebase;
  final String nombre_producto;
  final TipoProducto tipo_producto;
  final int cantidad;
  final double precio_unitario;
  final double subtotal;

  const DetalleFactura({
    this.id,
    this.id_factura,
    required this.id_producto_firebase,
    required this.nombre_producto,
    required this.tipo_producto,
    required this.cantidad,
    required this.precio_unitario,
    required this.subtotal,
  });

  factory DetalleFactura.crear({
    required String id_producto_firebase,
    required String nombre_producto,
    required TipoProducto tipo_producto,
    required int cantidad,
    required double precio_unitario,
    int? id_factura,
  }) {
    final subtotal = cantidad * precio_unitario;
    return DetalleFactura(
      id_producto_firebase: id_producto_firebase,
      nombre_producto: nombre_producto,
      tipo_producto: tipo_producto,
      cantidad: cantidad,
      precio_unitario: precio_unitario,
      subtotal: subtotal,
      id_factura: id_factura,
    );
  }

  factory DetalleFactura.fromJson(Map<String, dynamic> json) {
    return DetalleFactura(
      id: json['id'] as int?,
      id_factura: json['id_factura'] as int?,
      id_producto_firebase: json['id_producto_firebase'] as String? ?? '',
      nombre_producto: json['nombre_producto'] as String? ?? '',
      tipo_producto: TipoProductoExtension.fromString(json['tipo_producto'] as String? ?? ''),
      cantidad: json['cantidad'] as int? ?? 1,
      precio_unitario: (json['precio_unitario'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (id_factura != null) 'id_factura': id_factura,
      'id_producto_firebase': id_producto_firebase,
      'nombre_producto': nombre_producto,
      'tipo_producto': tipo_producto.valor,
      'cantidad': cantidad,
      'precio_unitario': precio_unitario,
      'subtotal': subtotal,
    };
  }

  @override
  List<Object?> get props => [id, id_factura, id_producto_firebase, nombre_producto, tipo_producto, cantidad, precio_unitario, subtotal];
}