import 'dart:convert';
import '../../domain/repositories/auth_repository.dart';

class AuthController {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  Future<String> login(Map<String, dynamic> body) async {
    try {
      final usuario = body['usuario'] as String? ?? '';
      final contrasena = body['contrasena'] as String? ?? '';

      if (usuario.isEmpty || contrasena.isEmpty) {
        return _respuestaError('Usuario y contraseña son requeridos');
      }

      // Intentar login como administrador
      final admin = await _authRepository.loginAdmin(usuario, contrasena);
      if (admin != null) {
        return _respuestaExitosa({
          'id': admin.id,
          'nombre': admin.nombre,
          'cargo': 'Administrador',
        });
      }

      // Intentar login como empleado
      final empleado = await _authRepository.loginEmpleado(usuario, contrasena);
      if (empleado != null) {
        return _respuestaExitosa({
          'id': empleado.id,
          'nombre': empleado.nombre,
          'cargo': empleado.cargo,
        });
      }

      return _respuestaError('Credenciales incorrectas');
    } catch (e) {
      return _respuestaError('Error al iniciar sesión: $e');
    }
  }

  Future<String> registrarAdmin(Map<String, dynamic> body) async {
    try {
      final nombre = body['nombre'] as String? ?? '';
      final contrasena = body['contrasena'] as String? ?? '';
      final confirmar = body['confirmar_contrasena'] as String? ?? '';

      if (nombre.isEmpty || contrasena.isEmpty) {
        return _respuestaError('Todos los campos son requeridos');
      }

      if (contrasena != confirmar) {
        return _respuestaError('Las contraseñas no coinciden');
      }

      final existe = await _authRepository.existeAdministrador();
      if (existe) {
        return _respuestaError('Ya existe un administrador registrado');
      }

      final admin = await _authRepository.registrarAdmin(nombre, contrasena);
      return _respuestaExitosa({
        'id': admin.id,
        'nombre': admin.nombre,
        'mensaje': 'Administrador registrado exitosamente',
      });
    } catch (e) {
      return _respuestaError('Error al registrar: $e');
    }
  }

  String _respuestaExitosa(dynamic data) {
    return json.encode({
      'success': true,
      'data': data,
    });
  }

  String _respuestaError(String mensaje) {
    return json.encode({
      'success': false,
      'message': mensaje,
    });
  }
}