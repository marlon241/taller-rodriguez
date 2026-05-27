import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../injection.dart';
import '../controllers/auth_controller.dart';

class AuthRoutes {
  final AuthController _authController;

  AuthRoutes() : _authController = getIt<AuthController>();

  Router get router {
    final router = Router();

    router.options('/api/<path|.*>', (Request request) async {
      return Response.ok('', headers: _corsHeaders);
    });

    router.post('/api/login', _login);
    router.post('/api/registro-admin', _registrarAdmin);

    return router;
  }

  Future<Response> _login(Request request) async {
    try {
      final body = await request.readAsString();
      Map<String, dynamic> data = {};
      if (body.isNotEmpty) {
        final decoded = json.decode(body);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      }
      final resultado = await _authController.login(data);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error al procesar la solicitud'}),
        headers: _jsonHeaders,
      );
    }
  }

  Future<Response> _registrarAdmin(Request request) async {
    try {
      final body = await request.readAsString();
      Map<String, dynamic> data = {};
      if (body.isNotEmpty) {
        final decoded = json.decode(body);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      }
      final resultado = await _authController.registrarAdmin(data);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error al procesar la solicitud'}),
        headers: _jsonHeaders,
      );
    }
  }

  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Accept, Authorization',
  };

  static const _corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Accept, Authorization',
  };
}