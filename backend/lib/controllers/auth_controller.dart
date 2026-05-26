// lib/controllers/auth_controller.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  
  static final _supabase = Supabase.instance.client;

  static Future<Map<String, dynamic>> login(
    String usuario,
    String contrasena,
  ) async {
    try {
      print('🔍 Intentando login con: Usuario="$usuario", Contraseña="$contrasena"');

      final response = await _supabase
          .from('empleados')
          .select()
          .or('nombre.eq.$usuario,dui.eq.$usuario')
          .eq('contrasena', contrasena)
          .eq('estado', true)
          .limit(1);

      print('📊 Respuesta de Supabase: ${response.length} registros encontrados');

      if (response.isNotEmpty) {
        final user = response.first;
        print('✅ Usuario encontrado: ${user['nombre']}');
        return {
          'success': true,
          'data': user,
          'message': '¡Bienvenido ${user['nombre']}!',
        };
      } else {
        print('❌ No se encontró el usuario');
        return {
          'success': false,
          'message': 'Usuario/DUI o contraseña incorrectos',
        };
      }
    } catch (e) {
      print('🚨 ERROR en login: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}