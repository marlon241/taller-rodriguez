import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../injection.dart';
import '../controllers/vehiculo_controller.dart';

class VehiculoRoutes {
  final VehiculoController _vehiculoController;

  VehiculoRoutes() : _vehiculoController = getIt<VehiculoController>();

  Router get router {
    final router = Router();

    router.get('/api/vehiculos/taller', _obtenerVehiculos);
    router.get('/api/vehiculos/<id>', _obtenerVehiculoPorId);
    router.post('/api/vehiculos', _crearVehiculo);
    router.put('/api/vehiculos/<id>', _actualizarVehiculo);
    router.delete('/api/vehiculos/<id>', _eliminarVehiculo);

    return router;
  }

  Future<Response> _obtenerVehiculos(Request request) async {
    final estado = request.url.queryParameters['estado'];
    final entregados = request.url.queryParameters['entregados'] == 'true';
    final resultado = await _vehiculoController.obtenerVehiculos(
      estado: estado,
      entregados: entregados,
    );
    return Response.ok(resultado, headers: _jsonHeaders);
  }

  Future<Response> _obtenerVehiculoPorId(Request request, String id) async {
    final idInt = int.tryParse(id);
    if (idInt == null) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'ID inválido'}),
        headers: _jsonHeaders,
      );
    }
    final resultado = await _vehiculoController.obtenerVehiculoPorId(idInt);
    return Response.ok(resultado, headers: _jsonHeaders);
  }

  Future<Response> _crearVehiculo(Request request) async {
    try {
      final body = await request.readAsString();
      Map<String, dynamic> data = {};
      if (body.isNotEmpty) {
        final decoded = json.decode(body);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      }
      final resultado = await _vehiculoController.crearVehiculo(data);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error al procesar la solicitud'}),
        headers: _jsonHeaders,
      );
    }
  }

  Future<Response> _actualizarVehiculo(Request request, String id) async {
    try {
      final idInt = int.tryParse(id);
      if (idInt == null) {
        return Response.badRequest(
          body: json.encode({'success': false, 'message': 'ID inválido'}),
          headers: _jsonHeaders,
        );
      }
      final body = await request.readAsString();
      Map<String, dynamic> data = {};
      if (body.isNotEmpty) {
        final decoded = json.decode(body);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      }
      final resultado = await _vehiculoController.actualizarVehiculo(idInt, data);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error al procesar la solicitud'}),
        headers: _jsonHeaders,
      );
    }
  }

  Future<Response> _eliminarVehiculo(Request request, String id) async {
    final idInt = int.tryParse(id);
    if (idInt == null) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'ID inválido'}),
        headers: _jsonHeaders,
      );
    }
    final resultado = await _vehiculoController.eliminarVehiculo(idInt);
    return Response.ok(resultado, headers: _jsonHeaders);
  }

  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Accept, Authorization',
  };
}