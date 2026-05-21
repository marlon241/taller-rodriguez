import 'dart:convert';
import 'package:http/http.dart' as http;

class SupabaseService {
  static const String _baseUrl = 'http://localhost:8080/api';

  // LOGIN
  static Future<Map<String, dynamic>> login(String usuario, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario': usuario,
          'contrasena': contrasena,
        }),
      );

      final data = jsonDecode(response.body);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al conectar con el servidor: $e',
      };
    }
  }

  // REGISTRO DE ADMINISTRADOR
  static Future<Map<String, dynamic>> registrarAdmin(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/registro-admin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': datos['nombre'],
          'contrasena': datos['contrasena'],
          'confirmar_contrasena': datos['confirmar_contrasena'],
        }),
      );

      final data = jsonDecode(response.body);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al conectar con el servidor: $e',
      };
    }
  }
}