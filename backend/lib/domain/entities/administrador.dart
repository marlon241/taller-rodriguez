import 'package:equatable/equatable.dart';

class Administrador extends Equatable {
  final int? id;
  final String nombre;
  final String contrasena;

  const Administrador({
    this.id,
    required this.nombre,
    required this.contrasena,
  });

  factory Administrador.fromJson(Map<String, dynamic> json) {
    return Administrador(
      id: json['id'] as int?,
      nombre: json['nombre'] as String? ?? '',
      contrasena: json['contrasena'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'contrasena': contrasena,
    };
  }

  @override
  List<Object?> get props => [id, nombre, contrasena];
}