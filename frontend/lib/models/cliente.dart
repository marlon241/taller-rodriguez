class Cliente {
  final int? id;
  final String nombre;
  final String telefono;
  final String dui;
  final String? correo;
  final String? direccion;
  final String frecuenciaVisita;
  final bool estado;
  final String? fechaRegistro;
  final String? nit;
  final String? nrc;

  const Cliente({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.dui,
    this.correo,
    this.direccion,
    required this.frecuenciaVisita,
    required this.estado,
    this.fechaRegistro,
    this.nit,
    this.nrc,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    bool parseEstado(dynamic valor) {
      if (valor == null) return true;
      if (valor is bool) return valor;
      if (valor is int) return valor != 0;
      if (valor is String) return valor == 'true' || valor == '1';
      return true;
    }

    String parseString(dynamic valor) {
      if (valor == null) return '';
      if (valor is String) return valor;
      return valor.toString();
    }

    return Cliente(
      id: json['id'] as int?,
      nombre: parseString(json['nombre']),
      telefono: parseString(json['telefono']),
      dui: parseString(json['dui']),
      correo: json['correo'] as String?,
      direccion: json['direccion'] as String?,
      frecuenciaVisita: parseString(json['frecuencia_visita']).isEmpty ? 'Regular' : parseString(json['frecuencia_visita']),
      estado: parseEstado(json['estado']),
      fechaRegistro: json['fecha_registro'] as String?,
      nit: json['nit'] == null ? null : parseString(json['nit']),
      nrc: json['nrc'] == null ? null : parseString(json['nrc']),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'telefono': telefono,
    'dui': dui,
    if (correo != null) 'correo': correo,
    if (direccion != null) 'direccion': direccion,
    'frecuencia_visita': frecuenciaVisita,
    'estado': estado,
    if (nit != null) 'nit': nit,
    if (nrc != null) 'nrc': nrc,
  };
}