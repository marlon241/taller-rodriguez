import 'package:equatable/equatable.dart';

enum EstadoOferta {
  activa,
  expirada,
}

extension EstadoOfertaExtension on EstadoOferta {
  String get valor {
    switch (this) {
      case EstadoOferta.activa:
        return 'Activa';
      case EstadoOferta.expirada:
        return 'Expirada';
    }
  }

  static EstadoOferta fromString(String value) {
    switch (value.toLowerCase()) {
      case 'activa':
        return EstadoOferta.activa;
      case 'expirada':
        return EstadoOferta.expirada;
      default:
        return EstadoOferta.expirada;
    }
  }
}

class Oferta extends Equatable {
  final int? id;
  final String nombre_oferta;
  final String descripcion;
  final double porcentaje_descuento;
  final DateTime fecha_inicio;
  final DateTime fecha_fin;
  final EstadoOferta estado_oferta;
  final String? id_producto_firebase;

  const Oferta({
    this.id,
    required this.nombre_oferta,
    required this.descripcion,
    required this.porcentaje_descuento,
    required this.fecha_inicio,
    required this.fecha_fin,
    required this.estado_oferta,
    this.id_producto_firebase,
  });

  bool get estaActiva {
    final ahora = DateTime.now();
    return estado_oferta == EstadoOferta.activa &&
           ahora.isAfter(fecha_inicio) &&
           ahora.isBefore(fecha_fin);
  }

  factory Oferta.fromJson(Map<String, dynamic> json) {
    return Oferta(
      id: json['id'] as int?,
      nombre_oferta: json['nombre_oferta'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      porcentaje_descuento: (json['porcentaje_descuento'] as num?)?.toDouble() ?? 0,
      fecha_inicio: json['fecha_inicio'] != null 
          ? DateTime.tryParse(json['fecha_inicio'].toString()) ?? DateTime.now()
          : DateTime.now(),
      fecha_fin: json['fecha_fin'] != null 
          ? DateTime.tryParse(json['fecha_fin'].toString()) ?? DateTime.now()
          : DateTime.now(),
      estado_oferta: EstadoOfertaExtension.fromString(json['estado_oferta'] as String? ?? ''),
      id_producto_firebase: json['id_producto_firebase'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre_oferta': nombre_oferta,
      'descripcion': descripcion,
      'porcentaje_descuento': porcentaje_descuento,
      'fecha_inicio': fecha_inicio.toIso8601String(),
      'fecha_fin': fecha_fin.toIso8601String(),
      'estado_oferta': estado_oferta.valor,
      'id_producto_firebase': id_producto_firebase,
    };
  }

  @override
  List<Object?> get props => [
    id, nombre_oferta, descripcion, porcentaje_descuento, 
    fecha_inicio, fecha_fin, estado_oferta, id_producto_firebase
  ];
}