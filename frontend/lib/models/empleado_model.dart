class EmpleadoModel {
  final int id;
  final String nombre;
  final String dui;
  final String telefono;
  final String cargo;
  final String contrasena;
  final bool estado;
  final double sueldoBase;
  final String fechaContratacion;
  final bool licencia;

  EmpleadoModel({
    required this.id,
    required this.nombre,
    required this.dui,
    required this.telefono,
    required this.cargo,
    required this.contrasena,
    required this.estado,
    required this.sueldoBase,
    required this.fechaContratacion,
    required this.licencia,
  });

  factory EmpleadoModel.fromJson(Map<String, dynamic> json) {
    return EmpleadoModel(
      id: json['id'],
      nombre: json['nombre'],
      dui: json['dui'],
      telefono: json['telefono'],
      cargo: json['cargo'],
      contrasena: json['contrasena'],
      estado: json['estado'],
      sueldoBase: json['sueldo_base'].toDouble(),
      fechaContratacion: json['fecha_contratacion'],
      licencia: json['licencia'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'dui': dui,
      'telefono': telefono,
      'cargo': cargo,
      'contrasena': contrasena,
      'estado': estado,
      'sueldo_base': sueldoBase,
      'fecha_contratacion': fechaContratacion,
      'licencia': licencia,
    };
  }
}