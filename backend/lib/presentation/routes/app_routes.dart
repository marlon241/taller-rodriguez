import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../injection.dart';
import '../controllers/facturacion_controller.dart';

class AppRoutes {
  final FacturacionController _facturacionController;
  
  AppRoutes() : _facturacionController = getIt<FacturacionController>();
  
  Router get router {
    final router = Router();
    
    router.options('/api/<path|.*>', (Request request) async {
      return Response.ok('', headers: _jsonHeaders);
    });
    
    router.get('/api/clientes', _obtenerClientes);
    router.get('/api/clientes/<id>/documentos', _obtenerDocumentosCliente);
    
    router.get('/api/vehiculos', _obtenerVehiculos);
    router.get('/api/vehiculos/<id>/documentos', _obtenerDocumentosVehiculo);
    
    router.get('/api/ofertas', _obtenerOfertas);
    
    router.get('/api/inventario', _obtenerInventario);
    
    router.get('/api/facturas', _obtenerFacturas);
    router.post('/api/facturas', _crearFactura);
    router.delete('/api/facturas/<id>', _eliminarFactura);
    
    router.all('/<path|.*>', _rutaNoEncontrada);
    
    return router;
  }
  
  Future<Response> _obtenerClientes(Request request) async {
    final resultado = await _facturacionController.obtenerClientes();
    return Response.ok(resultado, headers: _jsonHeaders);
  }
  
  Future<Response> _obtenerDocumentosCliente(Request request, String id) async {
    final resultado = await _facturacionController.obtenerDocumentosCliente(id);
    return Response.ok(resultado, headers: _jsonHeaders);
  }
  
  Future<Response> _obtenerVehiculos(Request request) async {
    final clienteId = request.url.queryParameters['clienteId'];
    final id = clienteId != null ? int.tryParse(clienteId) : null;
    final resultado = await _facturacionController.obtenerVehiculosPorCliente(id);
    return Response.ok(resultado, headers: _jsonHeaders);
  }
  
  Future<Response> _obtenerDocumentosVehiculo(Request request, String id) async {
    final resultado = await _facturacionController.obtenerDocumentosVehiculo(id);
    return Response.ok(resultado, headers: _jsonHeaders);
  }
  
  Future<Response> _obtenerOfertas(Request request) async {
    final resultado = await _facturacionController.obtenerOfertas();
    return Response.ok(resultado, headers: _jsonHeaders);
  }
  
  Future<Response> _obtenerInventario(Request request) async {
    final busqueda = request.url.queryParameters['busqueda'];
    final resultado = await _facturacionController.obtenerInventario(busqueda: busqueda);
    return Response.ok(resultado, headers: _jsonHeaders);
  }
  
  Future<Response> _obtenerFacturas(Request request) async {
    final resultado = await _facturacionController.obtenerFacturas();
    return Response.ok(resultado, headers: _jsonHeaders);
  }
  
  Future<Response> _crearFactura(Request request) async {
    try {
      final body = await request.readAsString();
      Map<String, dynamic> data = {};
      if (body.isNotEmpty) {
        final decoded = json.decode(body);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      }
      final resultado = await _facturacionController.crearFactura(data);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error al procesar la solicitud'}),
        headers: _jsonHeaders,
      );
    }
  }
  
  Future<Response> _eliminarFactura(Request request, String id) async {
    final idInt = int.tryParse(id);
    if (idInt == null) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'ID invalido'}),
        headers: _jsonHeaders,
      );
    }
    final resultado = await _facturacionController.eliminarFactura(idInt);
    return Response.ok(resultado, headers: _jsonHeaders);
  }
  
  Future<Response> _rutaNoEncontrada(Request request) async {
    return Response.notFound(
      json.encode({'success': false, 'message': 'Ruta no encontrada'}),
      headers: _jsonHeaders,
    );
  }
  
  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Accept, Authorization',
  };
}