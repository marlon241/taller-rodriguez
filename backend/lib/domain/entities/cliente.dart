import 'package:equatable/equatable.dart';

class Cliente extends Equatable {
  final int? id;
  final String nombre;
  final String telefono;
  final String dui;
  final String rtn;
  final String correo;
  final String direccion;
  final String frecuencia_visita;
  final bool estado;
  final DateTime? fecha_registro;

  const Cliente({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.dui,
    this.rtn = '',
    required this.correo,
    required this.direccion,
    required this.frecuencia_visita,
    required this.estado,
    this.fecha_registro,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int?,
      nombre: json['nombre'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      dui: json['dui'] as String? ?? '',
      rtn: json['rtn'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      frecuencia_visita: json['frecuencia_visita'] as String? ?? 'Regular',
      estado: json['estado'] as bool? ?? true,
      fecha_registro: json['fecha_registro'] != null 
          ? DateTime.tryParse(json['fecha_registro'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'dui': dui,
      'rtn': rtn,
      'correo': correo,
      'direccion': direccion,
      'frecuencia_visita': frecuencia_visita,
      'estado': estado,
      'fecha_registro': fecha_registro?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, nombre, telefono, dui, rtn, correo, direccion, frecuencia_visita, estado, fecha_registro];
}