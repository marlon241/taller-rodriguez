import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // LOGIN
  static Future<Map<String, dynamic>> login(String dui, String contrasena) async {
    try {
      final response = await _client
          .from('empleados')
          .select()
          .eq('dui', dui)
          .eq('contrasena', contrasena)
          .eq('estado', true)
          .single();

      return {
        'success': true,
        'message': 'Login exitoso',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'DUI o contraseña incorrectos',
      };
    }
  }

  // REGISTRO DE ADMINISTRADOR
  static Future<Map<String, dynamic>> registrarAdmin(Map<String, dynamic> datos) async {
    try {
      // Verificar que el DUI no exista
      final existe = await _client
          .from('empleados')
          .select('id')
          .eq('dui', datos['dui']);

      if (existe.isNotEmpty) {
        return {
          'success': false,
          'message': 'Ya existe un empleado con ese DUI',
        };
      }

      await _client.from('empleados').insert({
        'nombre': datos['nombre'],
        'dui': datos['dui'],
        'telefono': datos['telefono'],
        'contrasena': datos['contrasena'],
        'cargo': 'Administrador',
        'estado': true,
        'fecha_contratacion': DateTime.now().toIso8601String().split('T')[0],
        'sueldo_base': 0,
        'licencia': false,
      });

      return {
        'success': true,
        'message': 'Administrador registrado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al registrar: $e',
      };
    }
  }
}