import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://localhost:8080';

class FacturacionApi {
  final http.Client _client;
  
  FacturacionApi({http.Client? client}) : _client = client ?? http.Client();
  
  Future<List<Map<String, dynamic>>> obtenerClientes() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/api/clientes'));
      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> obtenerVehiculosPorCliente(int clienteId) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/vehiculos?clienteId=$clienteId'),
      );
      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
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
  
  Future<List<Map<String, dynamic>>> obtenerInventario({String? busqueda}) async {
    try {
      String url = '$_baseUrl/api/inventario';
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
  
  Future<List<Map<String, dynamic>>> obtenerFacturas() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/api/facturas'));
      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  Future<Map<String, dynamic>> crearFactura({
    required int idCliente,
    int? idVehiculo,
    required String tipoFactura,
    required List<Map<String, dynamic>> items,
    double descuentoPorcentaje = 0,
    int? idOferta,
    int? idCaja,
  }) async {
    try {
      if (descuentoPorcentaje > 100) {
        return {'success': false, 'message': 'El descuento no puede ser mayor a 100%'};
      }
      
      final body = json.encode({
        'id_cliente': idCliente,
        'id_vehiculo': idVehiculo,
        'tipo_factura': tipoFactura,
        'descuento_porcentaje': descuentoPorcentaje,
        'id_oferta': idOferta,
        'id_caja': idCaja,
        'items': items,
      });
      
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/facturas'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 15));
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error al crear factura: $e'};
    }
  }
  
  Future<Map<String, dynamic>?> obtenerFacturaPorId(int id) async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/api/facturas/$id'));
      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        return data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> eliminarFactura(int id) async {
    try {
      final response = await _client.delete(Uri.parse('$_baseUrl/api/facturas/$id'));
      final data = json.decode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<Uint8List?> descargarPdfFactura(int idFactura) async {
    try {
      final url = '$_baseUrl/api/facturas/$idFactura/pdf';
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Accept': 'application/pdf'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}