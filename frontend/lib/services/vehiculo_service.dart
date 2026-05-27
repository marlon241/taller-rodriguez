import 'dart:convert';
import 'package:http/http.dart' as http;

class VehiculoService {
  static const String _baseUrl = 'http://localhost:8080/api';

  // OBTENER VEHÍCULOS
  static Future<Map<String, dynamic>> obtenerVehiculos({bool entregados = false}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/vehiculos/taller?entregados=$entregados'),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      return {'success': false, 'message': 'Error al conectar con el servidor: $e'};
    }
  }

  // CREAR VEHÍCULO
  static Future<Map<String, dynamic>> crearVehiculo(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/vehiculos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );
      final data = jsonDecode(response.body);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      return {'success': false, 'message': 'Error al conectar con el servidor: $e'};
    }
  }

  // ACTUALIZAR VEHÍCULO
  static Future<Map<String, dynamic>> actualizarVehiculo(int id, Map<String, dynamic> datos) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/vehiculos/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );
      final data = jsonDecode(response.body);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      return {'success': false, 'message': 'Error al conectar con el servidor: $e'};
    }
  }

  // ELIMINAR VEHÍCULO
  static Future<Map<String, dynamic>> eliminarVehiculo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/vehiculos/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      return {'success': false, 'message': 'Error al conectar con el servidor: $e'};
    }
  }
}