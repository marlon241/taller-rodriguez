import 'package:equatable/equatable.dart';

class Proveedor extends Equatable {
  final int? id;
  final String nombre;
  final String telefono;
  final String correo;
  final String locacion;
  final String? nit;

  const Proveedor({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.locacion,
    this.nit,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'] as int?,
      nombre: json['nombre'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      locacion: json['locacion'] as String? ?? 'Nacional',
      nit: json['nit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'locacion': locacion,
      'nit': nit,
    };
  }

  @override
  List<Object?> get props => [id, nombre, telefono, correo, locacion, nit];
}