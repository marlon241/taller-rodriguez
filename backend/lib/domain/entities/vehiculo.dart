import 'package:equatable/equatable.dart';

class Vehiculo extends Equatable {
  final int? id;
  final String modelo;
  final String marca;
  final String placa;
  final int anio;
  final String diagnostico;
  final String estado;
  final DateTime? fecha_ingreso;
  final DateTime? fecha_salida;
  final int? id_cliente;
  final int? id_empleado;
  final String? urlImagenVehiculo;
  final String? urlTarjetaCirculacion;

  const Vehiculo({
    this.id,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.anio,
    required this.diagnostico,
    required this.estado,
    this.fecha_ingreso,
    this.fecha_salida,
    this.id_cliente,
    this.id_empleado,
    this.urlImagenVehiculo,
    this.urlTarjetaCirculacion,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'] as int?,
      modelo: json['modelo'] as String? ?? '',
      marca: json['marca'] as String? ?? '',
      placa: json['placa'] as String? ?? '',
      anio: json['anio'] as int? ?? 0,
      diagnostico: json['diagnostico'] as String? ?? '',
      estado: json['estado'] as String? ?? 'En revisión',
      fecha_ingreso: json['fecha_ingreso'] != null
          ? DateTime.tryParse(json['fecha_ingreso'].toString())
          : null,
      fecha_salida: json['fecha_salida'] != null
          ? DateTime.tryParse(json['fecha_salida'].toString())
          : null,
      id_cliente: json['id_cliente'] as int?,
      id_empleado: json['id_empleado'] as int?,
      urlImagenVehiculo: json['url_imagen_vehiculo'] as String?,
      urlTarjetaCirculacion: json['url_tarjeta_circulacion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'modelo': modelo,
      'marca': marca,
      'placa': placa,
      'anio': anio,
      'diagnostico': diagnostico,
      'estado': estado,
      'fecha_ingreso': fecha_ingreso?.toIso8601String(),
      'fecha_salida': fecha_salida?.toIso8601String(),
      'id_cliente': id_cliente,
      'id_empleado': id_empleado,
      if (urlImagenVehiculo != null) 'url_imagen_vehiculo': urlImagenVehiculo,
      if (urlTarjetaCirculacion != null) 'url_tarjeta_circulacion': urlTarjetaCirculacion,
    };
  }

  String get nombreCompleto => '$marca $modelo ($placa)';

  @override
  List<Object?> get props => [
    id, modelo, marca, placa, anio, diagnostico, estado,
    fecha_ingreso, fecha_salida, id_cliente, id_empleado,
    urlImagenVehiculo, urlTarjetaCirculacion,
  ];
}