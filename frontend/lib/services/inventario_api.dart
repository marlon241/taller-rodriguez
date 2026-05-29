import 'dart:convert';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://localhost:8080';

class InventarioApi {
  final http.Client _client;
  
  InventarioApi({http.Client? client}) : _client = client ?? http.Client();
  
  Future<List<Map<String, dynamic>>> obtenerInventario({
    String? busqueda,
    String? idProveedor,
    String? clasificacion,
    String? ordenStock,
  }) async {
    try {
      final params = <String>[];
      if (busqueda != null && busqueda.isNotEmpty) {
        params.add('busqueda=${Uri.encodeComponent(busqueda)}');
      }
      if (idProveedor != null && idProveedor.isNotEmpty) {
        params.add('idProveedor=${Uri.encodeComponent(idProveedor)}');
      }
      if (clasificacion != null && clasificacion.isNotEmpty) {
        params.add('clasificacion=${Uri.encodeComponent(clasificacion)}');
      }
      if (ordenStock != null && ordenStock.isNotEmpty) {
        params.add('ordenStock=${Uri.encodeComponent(ordenStock)}');
      }

      String url = '$_baseUrl/api/inventario';
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
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
  
  Future<Map<String, dynamic>> obtenerProductoPorId(String id) async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/api/inventario/$id'));
      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data'] ?? {});
      }
      return {};
    } catch (e) {
      return {};
    }
  }
  
  Future<Map<String, dynamic>> crearProducto(Map<String, dynamic> producto) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/inventario'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(producto),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error al crear producto: $e'};
    }
  }
  
  Future<Map<String, dynamic>> actualizarProducto(String id, Map<String, dynamic> producto) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/api/inventario/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(producto),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error al actualizar producto: $e'};
    }
  }
  
  Future<Map<String, dynamic>> entradaStock(String id, int cantidad, {String? motivo}) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/inventario/$id/stock');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'tipo': 'entrada',
          'cantidad': cantidad,
          'motivo': motivo,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.body.isEmpty) {
        return {'success': false, 'message': 'El servidor no devolvió respuesta'};
      }
      
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      String mensajeError = 'Error al agregar stock';
      if (e.toString().contains('Failed to fetch') || e.toString().contains('SocketException')) {
        mensajeError = 'No se pudo conectar al servidor. Verifique que el backend está corriendo.';
      } else if (e.toString().contains('TimeoutException')) {
        mensajeError = 'El servidor tardó demasiado en responder';
      }
      return {'success': false, 'message': mensajeError};
    }
  }
  
  Future<Map<String, dynamic>> salidaStock(String id, int cantidad, {String? motivo}) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/inventario/$id/stock');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'tipo': 'salida',
          'cantidad': cantidad,
          'motivo': motivo,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.body.isEmpty) {
        return {'success': false, 'message': 'El servidor no devolvió respuesta'};
      }
      
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      String mensajeError = 'Error al reducir stock';
      if (e.toString().contains('Failed to fetch') || e.toString().contains('SocketException')) {
        mensajeError = 'No se pudo conectar al servidor. Verifique que el backend está corriendo.';
      } else if (e.toString().contains('TimeoutException')) {
        mensajeError = 'El servidor tardó demasiado en responder';
      }
      return {'success': false, 'message': mensajeError};
    }
  }
  
  Future<bool> eliminarProducto(String id) async {
    try {
      final response = await _client.delete(Uri.parse('$_baseUrl/api/inventario/$id'));
      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}