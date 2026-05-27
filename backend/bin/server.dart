import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import '../lib/injection.dart';
import '../lib/presentation/routes/app_routes.dart';
import '../lib/presentation/routes/auth_routes.dart';
import '../lib/presentation/routes/vehiculo_routes.dart';

void main() async {
  configurarDependencias();

  final router = Router();

  router.mount('/', AuthRoutes().router);
  router.mount('/', VehiculoRoutes().router);
  router.mount('/', AppRoutes().router);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_customHeadersMiddleware())
      .addHandler(router);

  const ip = '0.0.0.0';
  const puerto = 8080;

  await shelf_io.serve(handler, ip, puerto);

  print('===========================================');
  print('  Servidor Backend - Taller Rodriguez');
  print('===========================================');
  print('  URL: http://localhost:$puerto');
  print('===========================================');
  print('');
  print('Endpoints disponibles:');
  print('  POST /api/login                 - Iniciar sesion');
  print('  POST /api/registro-admin        - Registrar administrador');
  print('  GET  /api/vehiculos/taller      - Listar vehiculos');
  print('  POST /api/vehiculos             - Crear vehiculo');
  print('  PUT  /api/vehiculos/<id>        - Actualizar vehiculo');
  print('  DELETE /api/vehiculos/<id>      - Eliminar vehiculo');
  print('  GET  /api/clientes              - Listar clientes');
  print('  GET  /api/ofertas               - Ofertas activas');
  print('  GET  /api/inventario            - Productos/Servicios');
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