import 'package:equatable/equatable.dart';

enum TipoInventario {
  producto,
  servicio,
}

extension TipoInventarioExtension on TipoInventario {
  String get valor {
    switch (this) {
      case TipoInventario.producto:
        return 'Producto';
      case TipoInventario.servicio:
        return 'Servicio';
    }
  }

  static TipoInventario fromString(String value) {
    switch (value.toLowerCase()) {
      case 'producto':
        return TipoInventario.producto;
      case 'servicio':
        return TipoInventario.servicio;
      default:
        return TipoInventario.producto;
    }
  }
}

class Producto extends Equatable {
  final String id;
  final String nombre;
  final TipoInventario tipo;
  final String clasificacion;
  final String descripcion;
  final String sku;
  final double precio_compra;
  final double precio_venta;
  final int stock;
  final int stock_minimo;
  final int stock_maximo;
  final String? id_proveedor;
  final DateTime? ultima_actualizacion;

  const Producto({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.clasificacion,
    required this.descripcion,
    required this.sku,
    required this.precio_compra,
    required this.precio_venta,
    required this.stock,
    required this.stock_minimo,
    required this.stock_maximo,
    this.id_proveedor,
    this.ultima_actualizacion,
  });

  factory Producto.fromJson(String id, Map<String, dynamic> json) {
    return Producto(
      id: id,
      nombre: json['nombre']?.toString() ?? '',
      tipo: TipoInventarioExtension.fromString(json['tipo']?.toString() ?? ''),
      clasificacion: json['clasificacion']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      precio_compra: _toDouble(json['precio_compra']),
      precio_venta: _toDouble(json['precio_venta']),
      stock: _toInt(json['stock']),
      stock_minimo: _toInt(json['stock_minimo']),
      stock_maximo: _toInt(json['stock_maximo']),
      id_proveedor: json['id_proveedor']?.toString(),
      ultima_actualizacion: json['ultima_actualizacion'] != null 
          ? DateTime.tryParse(json['ultima_actualizacion'].toString())
          : null,
    );
  }
  
  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
  
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
  
  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'tipo': tipo.valor,
      'clasificacion': clasificacion,
      'descripcion': descripcion,
      'sku': sku,
      'precio_compra': precio_compra,
      'precio_venta': precio_venta,
      'stock': stock,
      'stock_minimo': stock_minimo,
      'stock_maximo': stock_maximo,
      'id_proveedor': id_proveedor,
      'ultima_actualizacion': ultima_actualizacion?.toIso8601String(),
    };
  }

  bool get esProducto => tipo == TipoInventario.producto;
  bool get esServicio => tipo == TipoInventario.servicio;
  bool get tieneStock => esServicio || stock > 0;

  @override
  List<Object?> get props => [
    id, nombre, tipo, clasificacion, descripcion, sku, 
    precio_compra, precio_venta, stock, stock_minimo, 
    stock_maximo, id_proveedor, ultima_actualizacion
  ];
}