import '../services/supabase_service.dart';

class AuthController {
  
  static Future<Map<String, dynamic>> login(String dui, String contrasena) async {
    if (dui.isEmpty || contrasena.isEmpty) {
      return {
        'success': false,
        'message': 'DUI y contraseña son requeridos',
      };
    }

    return await SupabaseService.login(dui, contrasena);
  }

  
  static Future<Map<String, dynamic>> registrarAdmin(Map<String, dynamic> datos) async {
    if (datos['nombre'].isEmpty || datos['dui'].isEmpty ||
        datos['telefono'].isEmpty || datos['contrasena'].isEmpty) {
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
