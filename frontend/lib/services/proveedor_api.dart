import 'dart:convert';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://localhost:8080';

class ProveedorApi {
  final http.Client _client;

  ProveedorApi({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> obtenerProveedores({String? busqueda}) async {
    try {
      String url = '$_baseUrl/api/proveedores';
      if (busqueda != null && busqueda.isNotEmpty) {
        url += '?busqueda=${Uri.encodeComponent(busqueda)}';
      }

      final response = await _client.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> obtenerProveedorPorId(int id) async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/api/proveedores/$id'));
      final data = json.decode(response.body);

      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> crearProveedor(Map<String, dynamic> proveedor) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/proveedores'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(proveedor),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error al crear proveedor: $e'};
    }
  }

  Future<Map<String, dynamic>> actualizarProveedor(int id, Map<String, dynamic> proveedor) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/api/proveedores/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(proveedor),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error al actualizar proveedor: $e'};
    }
  }

  Future<Map<String, dynamic>> eliminarProveedor(int id) async {
    try {
      final response = await _client.delete(Uri.parse('$_baseUrl/api/proveedores/$id'));
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión al eliminar proveedor'};
    }
  }
}