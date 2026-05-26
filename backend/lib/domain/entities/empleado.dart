import 'package:equatable/equatable.dart';

class Empleado extends Equatable {
  final int? id;
  final String nombre;
  final String dui;
  final String telefono;
  final String cargo;
  final String contrasena;
  final bool estado;
  final double sueldoBase;
  final String fechaContratacion;
  final bool licencia;
  final double? porcentajeGanancia;

  const Empleado({
    this.id,
    required this.nombre,
    required this.dui,
    required this.telefono,
    required this.cargo,
    required this.contrasena,
    required this.estado,
    required this.sueldoBase,
    required this.fechaContratacion,
    required this.licencia,
    this.porcentajeGanancia,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['id'] as int?,
      nombre: json['nombre'] as String? ?? '',
      dui: json['dui'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      cargo: json['cargo'] as String? ?? '',
      contrasena: json['contrasena'] as String? ?? '',
      estado: json['estado'] as bool? ?? true,
      sueldoBase: (json['sueldo_base'] as num?)?.toDouble() ?? 0.0,
      fechaContratacion: json['fecha_contratacion'] as String? ?? '',
      licencia: json['licencia'] as bool? ?? false,
      porcentajeGanancia:
          (json['porcentaje_ganancia'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'dui': dui,
      'telefono': telefono,
      'cargo': cargo,
      'contrasena': contrasena,
      'estado': estado,
      'sueldo_base': sueldoBase,
      'fecha_contratacion': fechaContratacion,
      'licencia': licencia,
      if (porcentajeGanancia != null)
        'porcentaje_ganancia': porcentajeGanancia,
    };
  }

  Empleado copyWith({
    int? id,
    String? nombre,
    String? dui,
    String? telefono,
    String? cargo,
    String? contrasena,
    bool? estado,
    double? sueldoBase,
    String? fechaContratacion,
    bool? licencia,
    double? porcentajeGanancia,
  }) {
    return Empleado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      dui: dui ?? this.dui,
      telefono: telefono ?? this.telefono,
      cargo: cargo ?? this.cargo,
      contrasena: contrasena ?? this.contrasena,
      estado: estado ?? this.estado,
      sueldoBase: sueldoBase ?? this.sueldoBase,
      fechaContratacion: fechaContratacion ?? this.fechaContratacion,
      licencia: licencia ?? this.licencia,
      porcentajeGanancia: porcentajeGanancia ?? this.porcentajeGanancia,
    );
  }

  @override
  List<Object?> get props => [
        id, nombre, dui, telefono, cargo,
        estado, sueldoBase, fechaContratacion,
        licencia, porcentajeGanancia,
      ];
}