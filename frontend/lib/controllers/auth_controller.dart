import '../services/supabase_service.dart';

class AuthController {
  // LOGIN
  static Future<Map<String, dynamic>> login(String usuario, String contrasena) async {
    if (usuario.isEmpty || contrasena.isEmpty) {
      return {
        'success': false,
        'message': 'Usuario y contraseña son requeridos',
      };
    }
    return await SupabaseService.login(usuario, contrasena);
  }

  // REGISTRO DE ADMINISTRADOR
  static Future<Map<String, dynamic>> registrarAdmin(Map<String, dynamic> datos) async {
    if ((datos['nombre'] ?? '').isEmpty || (datos['contrasena'] ?? '').isEmpty) {
      return {
        'success': false,
        'message': 'Todos los campos son requeridos',
      };
    }

    if (datos['contrasena'] != datos['confirmar_contrasena']) {
      return {
        'success': false,
        'message': 'Las contraseñas no coinciden',
      };
    }

    return await SupabaseService.registrarAdmin(datos);
  }
}