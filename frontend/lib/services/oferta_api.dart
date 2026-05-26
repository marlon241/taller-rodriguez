import 'dart:convert';
import 'package:http/http.dart' as http;

class OfertaApi {
  final String _baseUrl;
  final http.Client _client;

  OfertaApi({String? baseUrl, http.Client? client})
      : _baseUrl = baseUrl ?? 'http://localhost:8080',
        _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> obtenerOfertas() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/api/ofertas'));
      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> obtenerOfertaPorId(int id) async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/api/ofertas/$id'));
      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        return data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> crearOferta({
    required String nombreOferta,
    required String descripcion,
    required double porcentajeDescuento,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? idProductoFirebase,
  }) async {
    try {
      final body = json.encode({
        'nombre_oferta': nombreOferta,
        'descripcion': descripcion,
        'porcentaje_descuento': porcentajeDescuento,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        'id_producto_firebase': idProductoFirebase,
      });

      final response = await _client.post(
        Uri.parse('$_baseUrl/api/ofertas'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 15));

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error al crear oferta: $e'};
    }
  }

  Future<Map<String, dynamic>> actualizarOferta({
    required int id,
    required String nombreOferta,
    required String descripcion,
    required double porcentajeDescuento,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    String? idProductoFirebase,
  }) async {
    try {
      final body = json.encode({
        'nombre_oferta': nombreOferta,
        'descripcion': descripcion,
        'porcentaje_descuento': porcentajeDescuento,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        'id_producto_firebase': idProductoFirebase,
      });

      final response = await _client.put(
        Uri.parse('$_baseUrl/api/ofertas/$id'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 15));

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error al actualizar oferta: $e'};
    }
  }

  Future<Map<String, dynamic>> eliminarOferta(int id) async {
    try {
      final response = await _client.delete(Uri.parse('$_baseUrl/api/ofertas/$id'));
      final data = json.decode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión al eliminar oferta'};
    }
  }
}