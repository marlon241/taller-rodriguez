import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import '../lib/injection.dart';
import '../lib/presentation/routes/app_routes.dart';

void main() async {
  configurarDependencias();

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_customHeadersMiddleware())
      .addHandler(AppRoutes().router);

  const ip = '0.0.0.0';
  const puerto = 8080;

  await shelf_io.serve(handler, ip, puerto);

  print('===========================================');
  print('  Servidor Backend - Taller Rodriguez');
  print('===========================================');
  print('  URL: http://localhost:$puerto');
  print('  Modulo: Facturacion');
  print('===========================================');
  print('');
  print('Endpoints disponibles:');
  print('  GET  /api/clientes              - Listar clientes');
  print('  GET  /api/vehiculos?clienteId=  - Vehiculos por cliente');
  print('  GET  /api/ofertas               - Ofertas activas');
  print('  GET  /api/inventario            - Productos/Servicios (Firebase)');
  print('  GET  /api/inventario?busqueda=  - Buscar inventario');
  print('  GET  /api/facturas              - Listar facturas');
  print('  POST /api/facturas              - Crear factura');
  print('  DELETE /api/facturas/<id>       - Eliminar factura');
  print('===========================================');
}

Middleware _customHeadersMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);
      return response.change(
        headers: {
          'X-Powered-By': 'Dart/Shelf',
          'X-Framework': 'Clean Architecture',
        },
      );
    };
  };
}