import 'dart:convert';
import 'dart:async';
import '../../domain/entities/cliente.dart';
import '../../domain/entities/vehiculo.dart';
import '../../domain/entities/factura.dart';
import '../../domain/entities/detalle_factura.dart';
import '../../domain/entities/producto.dart';
import '../../domain/entities/oferta.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../../domain/repositories/vehiculo_repository.dart';
import '../../domain/repositories/inventario_repository.dart';
import '../../domain/repositories/oferta_repository.dart';
import '../../domain/repositories/factura_repository.dart';

class FacturacionController {
  final ClienteRepository _clienteRepository;
  final VehiculoRepository _vehiculoRepository;
  final InventarioRepository _inventarioRepository;
  final OfertaRepository _ofertaRepository;
  final FacturaRepository _facturaRepository;
  
  final List<StreamSubscription> _suscripciones = [];
  
  FacturacionController({
    required ClienteRepository clienteRepository,
    required VehiculoRepository vehiculoRepository,
    required InventarioRepository inventarioRepository,
    required OfertaRepository ofertaRepository,
    required FacturaRepository facturaRepository,
  })  : _clienteRepository = clienteRepository,
        _vehiculoRepository = vehiculoRepository,
        _inventarioRepository = inventarioRepository,
        _ofertaRepository = ofertaRepository,
        _facturaRepository = facturaRepository;
  
  Future<String> obtenerClientes() async {
    try {
      final stream = _clienteRepository.obtenerClientes();
      
      final clientes = await stream.first;
      
      return _respuestaExitosa(
        clientes.map((c) => {
          'id': c.id,
          'nombre': c.nombre,
          'telefono': c.telefono,
          'dui': c.dui,
          'correo': c.correo,
        }).toList(),
      );
    } catch (e) {
      return _respuestaError('Error al obtener clientes: $e');
    }
  }
  
  Future<String> obtenerDocumentosCliente(String idCliente) async {
    try {
      return _respuestaExitosa([]);
    } catch (e) {
      return _respuestaError('Error al obtener documentos: $e');
    }
  }
  
  Future<String> obtenerVehiculosPorCliente(int? idCliente) async {
    try {
      if (idCliente == null) {
        return _respuestaError('Se requiere el ID del cliente');
      }
      
      final stream = _vehiculoRepository.obtenerVehiculosPorCliente(idCliente);
      final vehiculos = await stream.first;
      
      return _respuestaExitosa(
        vehiculos.map((v) => {
          'id': v.id,
          'modelo': v.modelo,
          'marca': v.marca,
          'placa': v.placa,
          'anio': v.anio,
          'estado': v.estado,
        }).toList(),
      );
    } catch (e) {
      return _respuestaError('Error al obtener vehículos: $e');
    }
  }
  
  Future<String> obtenerDocumentosVehiculo(String idVehiculo) async {
    try {
      return _respuestaExitosa([]);
    } catch (e) {
      return _respuestaError('Error al obtener documentos: $e');
    }
  }
  
  Future<String> obtenerOfertas() async {
    try {
      final stream = _ofertaRepository.obtenerOfertasActivas();
      final ofertas = await stream.first;
      
      return _respuestaExitosa(
        ofertas.map((o) => {
          'id': o.id,
          'nombre_oferta': o.nombre_oferta,
          'descripcion': o.descripcion,
          'porcentaje_descuento': o.porcentaje_descuento,
          'fecha_inicio': o.fecha_inicio.toIso8601String(),
          'fecha_fin': o.fecha_fin.toIso8601String(),
          'id_producto_firebase': o.id_producto_firebase,
        }).toList(),
      );
    } catch (e) {
      return _respuestaError('Error al obtener ofertas: $e');
    }
  }
  
  Future<String> obtenerInventario({String? busqueda}) async {
    try {
      Stream<List<Producto>> stream;
      
      if (busqueda != null && busqueda.isNotEmpty) {
        stream = _inventarioRepository.buscarInventario(busqueda);
      } else {
        stream = _inventarioRepository.obtenerInventario();
      }
      
      final productos = await stream.first;
      
      return _respuestaExitosa(
        productos.map((p) => {
          'id': p.id,
          'nombre': p.nombre,
          'tipo': p.tipo.valor,
          'precio_venta': p.precio_venta,
          'stock': p.stock,
          'clasificacion': p.clasificacion,
        }).toList(),
      );
    } catch (e) {
      return _respuestaError('Error al obtener inventario: $e');
    }
  }
  
  Future<String> obtenerFacturas() async {
    try {
      final stream = _facturaRepository.obtenerFacturas();
      final facturas = await stream.first;
      
      return _respuestaExitosa(
        facturas.map((f) => {
          'id': f.id,
          'fecha': f.fecha.toIso8601String(),
          'tipo_factura': f.tipo_factura.valor,
          'subtotal': f.subtotal,
          'iva': f.iva,
          'descuento': f.descuento,
          'total': f.total,
          'id_cliente': f.id_cliente,
          'id_vehiculo': f.id_vehiculo,
          'detalles': f.detalles.map((d) => d.toJson()).toList(),
        }).toList(),
      );
    } catch (e) {
      return _respuestaError('Error al obtener facturas: $e');
    }
  }
  
  Future<String> crearFactura(Map<String, dynamic> body) async {
    try {
      if (body['id_cliente'] == null) {
        return _respuestaError('El cliente es requerido');
      }
      
      if (body['items'] == null || (body['items'] as List).isEmpty) {
        return _respuestaError('Debe incluir al menos un ítem en la factura');
      }
      
      final tipoFacturaStr = body['tipo_factura'] as String? ?? 'Consumidor Final';
      final tipoFactura = TipoFacturaExtension.fromString(tipoFacturaStr);
      
      final descuentoPorcentaje = (body['descuento_porcentaje'] as num?)?.toDouble() ?? 0.0;
      
      final items = (body['items'] as List).map((item) {
        final itemMap = item as Map<String, dynamic>;
        return DetalleFactura.crear(
          id_producto_firebase: itemMap['id_producto'] as String? ?? '',
          nombre_producto: itemMap['nombre'] as String? ?? '',
          tipo_producto: TipoProductoExtension.fromString(itemMap['tipo'] as String? ?? ''),
          cantidad: itemMap['cantidad'] as int? ?? 1,
          precio_unitario: (itemMap['precio_unitario'] as num?)?.toDouble() ?? 0,
        );
      }).toList();
      
      final factura = Factura.crear(
        fecha: DateTime.now(),
        tipo_factura: tipoFactura,
        detalles: items,
        descuentoPorcentaje: descuentoPorcentaje,
        id_cliente: body['id_cliente'] as int?,
        id_vehiculo: body['id_vehiculo'] as int?,
        id_oferta: body['id_oferta'] as int?,
        id_caja: body['id_caja'] as int?,
      );
      
      final facturaCreada = await _facturaRepository.crearFactura(factura);
      
      return _respuestaExitosa({
        'id': facturaCreada.id,
        'mensaje': 'Factura creada exitosamente',
        'factura': {
          'subtotal': facturaCreada.subtotal,
          'iva': facturaCreada.iva,
          'descuento': facturaCreada.descuento,
          'total': facturaCreada.total,
        },
      });
    } catch (e) {
      return _respuestaError('Error al crear factura: $e');
    }
  }
  
  Future<String> eliminarFactura(int id) async {
    try {
      final resultado = await _facturaRepository.eliminarFactura(id);
      
      if (resultado) {
        return _respuestaExitosa({'mensaje': 'Factura eliminada exitosamente'});
      }
      
      return _respuestaError('No se pudo eliminar la factura');
    } catch (e) {
      return _respuestaError('Error al eliminar factura: $e');
    }
  }
  
  String _respuestaExitosa(dynamic data) {
    return json.encode({
      'success': true,
      'data': data,
    });
  }
  
  String _respuestaError(String mensaje) {
    return json.encode({
      'success': false,
      'message': mensaje,
    });
  }
  
  void dispose() {
    for (final suscripcion in _suscripciones) {
      suscripcion.cancel();
    }
    _suscripciones.clear();
  }
}