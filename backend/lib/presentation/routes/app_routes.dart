import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../injection.dart';
import '../controllers/facturacion_controller.dart';
import '../controllers/factura_pdf_controller.dart';
import '../controllers/oferta_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/inventario_controller.dart';
import '../controllers/proveedor_controller.dart';

class AppRoutes {
  final FacturacionController _facturacionController;
  final FacturaPdfController _facturaPdfController;
  final OfertaController _ofertaController;
  final AuthController _authController;
  final InventarioController _inventarioController;
  final ProveedorController _proveedorController;

  AppRoutes()
      : _facturacionController = getIt<FacturacionController>(),
        _facturaPdfController = getIt<FacturaPdfController>(),
        _ofertaController = getIt<OfertaController>(),
        _authController = getIt<AuthController>(),
        _inventarioController = getIt<InventarioController>(),
        _proveedorController = getIt<ProveedorController>();
  
  Router get router {
    final router = Router();

    router.options('/<path|.*>', (Request request) async {
      return Response.ok('', headers: _jsonHeaders);
    });

    router.post('/api/login', _login);
    router.post('/api/registro-admin', _registrarAdmin);

    router.get('/api/clientes', _obtenerClientes);
    router.get('/api/clientes/<id>/documentos', _obtenerDocumentosCliente);

    router.get('/api/vehiculos', _obtenerVehiculos);
    router.get('/api/vehiculos/<id>/documentos', _obtenerDocumentosVehiculo);

    router.get('/api/ofertas', _obtenerOfertas);
    router.post('/api/ofertas', _crearOferta);
    router.put('/api/ofertas/<id>', _actualizarOferta);
    router.delete('/api/ofertas/<id>', _eliminarOferta);

    router.get('/api/inventario', _obtenerInventario);
    router.get('/api/inventario/<id>', _obtenerProductoPorId);
    router.post('/api/inventario', _crearProducto);
    router.put('/api/inventario/<id>', _actualizarProducto);
    router.post('/api/inventario/<id>/stock', _actualizarStock);
    router.delete('/api/inventario/<id>', _eliminarProducto);

    router.get('/api/facturas', _obtenerFacturas);
    router.get('/api/facturas/<id>/pdf', _obtenerFacturaPdf);
    router.post('/api/facturas', _crearFactura);
    router.delete('/api/facturas/<id>', _eliminarFactura);

    router.get('/api/proveedores', _obtenerProveedores);
    router.get('/api/proveedores/<id>', _obtenerProveedorPorId);
    router.post('/api/proveedores', _crearProveedor);
    router.put('/api/proveedores/<id>', _actualizarProveedor);
    router.delete('/api/proveedores/<id>', _eliminarProveedor);

    router.all('/<path|.*>', _rutaNoEncontrada);

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
    final resultado = await _ofertaController.obtenerOfertas();
    return Response.ok(resultado, headers: _jsonHeaders);
  }
  
  Future<Response> _crearOferta(Request request) async {
    try {
      final body = await request.readAsString();
      Map<String, dynamic> data = {};
      if (body.isNotEmpty) {
        final decoded = json.decode(body);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      }
      final resultado = await _ofertaController.crearOferta(data);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error al parsear el cuerpo de la solicitud'}),
        headers: _jsonHeaders,
      );
    }
  }
  
  Future<Response> _actualizarOferta(Request request, String id) async {
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
      final resultado = await _ofertaController.actualizarOferta(idInt, data);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error al parsear el cuerpo de la solicitud'}),
        headers: _jsonHeaders,
      );
    }
  }
  
  Future<Response> _eliminarOferta(Request request, String id) async {
    final idInt = int.tryParse(id);
    if (idInt == null) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'ID inválido'}),
        headers: _jsonHeaders,
      );
    }
    final resultado = await _ofertaController.eliminarOferta(idInt);
    return Response.ok(resultado, headers: _jsonHeaders);
  }
  
  Future<Response> _obtenerInventario(Request request) async {
    final busqueda = request.url.queryParameters['busqueda'];
    final idProveedor = request.url.queryParameters['idProveedor'];
    final clasificacion = request.url.queryParameters['clasificacion'];
    final ordenStock = request.url.queryParameters['ordenStock'];
    final resultado = await _inventarioController.obtenerInventario(
      busqueda: busqueda,
      idProveedor: idProveedor,
      clasificacion: clasificacion,
      ordenStock: ordenStock,
    );
    return Response.ok(resultado, headers: _jsonHeaders);
  }
  
  Future<Response> _obtenerProductoPorId(Request request, String id) async {
    final resultado = await _inventarioController.obtenerProductoPorId(id);
    return Response.ok(resultado, headers: _jsonHeaders);
  }
  
  Future<Response> _crearProducto(Request request) async {
    try {
      final body = await request.readAsString();
      Map<String, dynamic> data = {};
      if (body.isNotEmpty) {
        final decoded = json.decode(body);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      }
      final resultado = await _inventarioController.crearProducto(data);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error al procesar la solicitud'}),
        headers: _jsonHeaders,
      );
    }
  }
  
  Future<Response> _actualizarProducto(Request request, String id) async {
    try {
      final body = await request.readAsString();
      Map<String, dynamic> data = {};
      if (body.isNotEmpty) {
        final decoded = json.decode(body);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      }
      final resultado = await _inventarioController.actualizarProducto(id, data);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error al procesar la solicitud'}),
        headers: _jsonHeaders,
      );
    }
  }
  
  Future<Response> _actualizarStock(Request request, String id) async {
    try {
      final body = await request.readAsString();
      Map<String, dynamic> data = {};
      if (body.isNotEmpty) {
        final decoded = json.decode(body);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      }
      
      final tipo = data['tipo'] as String? ?? 'entrada';
      final cantidad = (data['cantidad'] as num?)?.toInt() ?? 0;
      final motivo = data['motivo'] as String?;
      
      String resultado;
      if (tipo == 'salida') {
        resultado = await _inventarioController.salidaStock(id, cantidad, motivo: motivo);
      } else {
        resultado = await _inventarioController.entradaStock(id, cantidad, motivo: motivo);
      }
      
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error al procesar la solicitud'}),
        headers: _jsonHeaders,
      );
    }
  }
  
  Future<Response> _eliminarProducto(Request request, String id) async {
    final resultado = await _inventarioController.eliminarProducto(id);
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

  Future<Response> _obtenerFacturaPdf(Request request, String id) async {
    final idInt = int.tryParse(id);
    if (idInt == null) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'ID invalido'}),
        headers: _jsonHeaders,
      );
    }
    final resultado = await _facturaPdfController.obtenerFacturaPdf(idInt);
    return Response.ok(resultado, headers: _jsonHeaders);
  }

  Future<Response> _obtenerProveedores(Request request) async {
    try {
      final busqueda = request.url.queryParameters['busqueda'];
      final resultado = await _proveedorController.obtenerProveedores(busqueda: busqueda);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'success': false, 'message': 'Error al obtener proveedores'}),
        headers: _jsonHeaders,
      );
    }
  }

  Future<Response> _obtenerProveedorPorId(Request request, String id) async {
    try {
      final idInt = int.tryParse(id);
      if (idInt == null) {
        return Response.badRequest(
          body: json.encode({'success': false, 'message': 'ID inválido'}),
          headers: _jsonHeaders,
        );
      }
      final resultado = await _proveedorController.obtenerProveedorPorId(idInt);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'success': false, 'message': 'Error al obtener proveedor'}),
        headers: _jsonHeaders,
      );
    }
  }

  Future<Response> _crearProveedor(Request request) async {
    try {
      final body = await request.readAsString();
      Map<String, dynamic> data = {};
      if (body.isNotEmpty) {
        final decoded = json.decode(body);
        if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      }
      final resultado = await _proveedorController.crearProveedor(data);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error al crear proveedor'}),
        headers: _jsonHeaders,
      );
    }
  }

  Future<Response> _actualizarProveedor(Request request, String id) async {
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
      final resultado = await _proveedorController.actualizarProveedor(idInt, data);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.badRequest(
        body: json.encode({'success': false, 'message': 'Error al actualizar proveedor'}),
        headers: _jsonHeaders,
      );
    }
  }

  Future<Response> _eliminarProveedor(Request request, String id) async {
    try {
      final idInt = int.tryParse(id);
      if (idInt == null) {
        return Response.badRequest(
          body: json.encode({'success': false, 'message': 'ID inválido'}),
          headers: _jsonHeaders,
        );
      }
      final resultado = await _proveedorController.eliminarProveedor(idInt);
      return Response.ok(resultado, headers: _jsonHeaders);
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'success': false, 'message': 'Error al eliminar proveedor'}),
        headers: _jsonHeaders,
      );
    }
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
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Accept, Authorization',
  };
}