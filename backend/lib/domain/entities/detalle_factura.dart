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
  final String id_producto;
  final String nombre_producto;
  final String tipo_producto;
  final String? clasificacion;
  final String? descripcion;
  final String? sku;
  final int cantidad;
  final double precio_unitario;
  final double subtotal;

  const DetalleFactura({
    this.id,
    this.id_factura,
    required this.id_producto,
    required this.nombre_producto,
    required this.tipo_producto,
    this.clasificacion,
    this.descripcion,
    this.sku,
    required this.cantidad,
    required this.precio_unitario,
    required this.subtotal,
  });

  factory DetalleFactura.crear({
    required String id_producto,
    required String nombre_producto,
    required String tipo_producto,
    String? clasificacion,
    String? descripcion,
    String? sku,
    required int cantidad,
    required double precio_unitario,
    int? id_factura,
  }) {
    final subtotal = cantidad * precio_unitario;
    return DetalleFactura(
      id_producto: id_producto,
      nombre_producto: nombre_producto,
      tipo_producto: tipo_producto,
      clasificacion: clasificacion,
      descripcion: descripcion,
      sku: sku,
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
      id_producto: (json['id_producto'] ?? json['id_producto_firebase'] ?? '').toString(),
      nombre_producto: json['nombre_producto'] as String? ?? '',
      tipo_producto: json['tipo_producto'] as String? ?? 'Producto',
      clasificacion: json['clasificacion'] as String?,
      descripcion: json['descripcion'] as String?,
      sku: json['sku'] as String?,
      cantidad: json['cantidad'] as int? ?? 1,
      precio_unitario: (json['precio_unitario'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (id_factura != null) 'id_factura': id_factura,
      'id_producto': id_producto,
      'nombre_producto': nombre_producto,
      'tipo_producto': tipo_producto,
      if (clasificacion != null) 'clasificacion': clasificacion,
      if (descripcion != null) 'descripcion': descripcion,
      if (sku != null) 'sku': sku,
      'cantidad': cantidad,
      'precio_unitario': precio_unitario,
      'subtotal': subtotal,
    };
  }

  bool get esProducto => tipo_producto.toLowerCase() == 'producto';
  bool get esServicio => tipo_producto.toLowerCase() == 'servicio';

  @override
  List<Object?> get props => [id, id_factura, id_producto, nombre_producto, tipo_producto, clasificacion, descripcion, sku, cantidad, precio_unitario, subtotal];
}