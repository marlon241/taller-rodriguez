import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/services/session_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'session_service.dart';

class SupabaseService {
  
  static final _client = Supabase.instance.client;

  // ====================== LOGIN ======================
  static Future<Map<String, dynamic>> login(
    String usuario,
    String contrasena,
  ) async {
    try {
      final response = await _client
          .from('empleados')
          .select()
          .or('nombre.eq.$usuario,dui.eq.$usuario')
          .eq('contrasena', contrasena)
          .eq('estado', true)
          .limit(1);

      if (response.isNotEmpty) {
        final user = response.first;

        SessionService.iniciar(user);   // Guardar sesión

        return {
          'success': true,
          'message': '¡Bienvenido ${user['nombre']}!',
          'empleado': user,
        };
      } else {
        return {
          'success': false,
          'message': 'Usuario o contraseña incorrectos',
        };
      }
    } catch (e) {
      print('Error en login: $e');
      return {
        'success': false,
        'message': 'Error de conexión',
      };
    }
  }

  // ====================== REGISTRO ADMIN ======================
  static Future<Map<String, dynamic>> registrarAdmin(
    Map<String, dynamic> datos,
  ) async {
    try {
      final response = await _client
          .from('empleados')
          .insert({
            'nombre': datos['nombre'],
            'dui': datos['dui'] ?? 'TEMP-${DateTime.now().millisecondsSinceEpoch}',
            'telefono': datos['telefono'] ?? '00000000',
            'fecha_contratacion': DateTime.now().toIso8601String().split('T')[0],
            'sueldo_base': datos['sueldo_base'] ?? 0,
            'contrasena': datos['contrasena'],
            'cargo': 'Administrador',
            'tipo_empleado': datos['tipo_empleado'] ?? 'contratado',
            'estado': true,
          })
          .select()
          .single();

      return {
        'success': true,
        'message': 'Administrador registrado correctamente',
        'data': response,
      };
    } catch (e) {
      print('Error al registrar admin: $e');
      return {
        'success': false,
        'message': 'Error al registrar',
      };
    }
  }
}