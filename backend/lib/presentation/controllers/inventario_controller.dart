import 'dart:convert';
import 'dart:async';
import '../../domain/entities/producto.dart';
import '../../domain/repositories/inventario_repository.dart';

class InventarioController {
  final InventarioRepository _repository;
  
  final List<StreamSubscription> _suscripciones = [];
  
  InventarioController({required InventarioRepository repository})
      : _repository = repository;
  
  Future<String> obtenerInventario({
    String? busqueda,
    String? idProveedor,
    String? clasificacion,
    String? ordenStock,
  }) async {
    try {
      Stream<List<Producto>> stream;

      final tieneFiltros = (idProveedor != null && idProveedor.isNotEmpty) ||
                           (clasificacion != null && clasificacion.isNotEmpty) ||
                           (busqueda != null && busqueda.isNotEmpty) ||
                           (ordenStock != null && ordenStock.isNotEmpty);

      if (tieneFiltros) {
        stream = _repository.buscarInventario(
          busqueda ?? '',
          idProveedor: idProveedor,
          clasificacion: clasificacion,
          ordenStock: ordenStock,
        );
      } else {
        stream = _repository.obtenerInventario();
      }

      final productos = await stream.first;
      
      return _respuestaExitosa(
        productos.map((p) => {
          'id': p.id,
          'nombre': p.nombre,
          'tipo': p.tipo.valor,
          'clasificacion': p.clasificacion,
          'descripcion': p.descripcion,
          'sku': p.sku,
          'precio_compra': p.precio_compra,
          'precio_venta': p.precio_venta,
          'stock': p.stock,
          'stock_minimo': p.stock_minimo,
          'stock_maximo': p.stock_maximo,
          'id_proveedor': p.id_proveedor,
        }).toList(),
      );
    } catch (e) {
      return _respuestaError('Error al obtener inventario: $e');
    }
  }
  
  Future<String> obtenerProductoPorId(String id) async {
    try {
      final producto = await _repository.obtenerProductoPorId(id);
      
      if (producto == null) {
        return _respuestaError('Producto no encontrado');
      }
      
      return _respuestaExitosa({
        'id': producto.id,
        'nombre': producto.nombre,
        'tipo': producto.tipo.valor,
        'clasificacion': producto.clasificacion,
        'descripcion': producto.descripcion,
        'sku': producto.sku,
        'precio_compra': producto.precio_compra,
        'precio_venta': producto.precio_venta,
        'stock': producto.stock,
        'stock_minimo': producto.stock_minimo,
        'stock_maximo': producto.stock_maximo,
        'id_proveedor': producto.id_proveedor,
      });
    } catch (e) {
      return _respuestaError('Error al obtener producto: $e');
    }
  }
  
  Future<String> crearProducto(Map<String, dynamic> data) async {
    try {
      final stock = (data['stock'] as num?)?.toInt() ?? 0;
      final stockMaximo = (data['stock_maximo'] as num?)?.toInt() ?? 0;
      final stockMinimo = (data['stock_minimo'] as num?)?.toInt() ?? 0;
      
      if (stock > 999) {
        return _respuestaError('El stock no puede exceder 999 unidades');
      }
      if (stockMaximo > 999) {
        return _respuestaError('El stock máximo no puede exceder 999 unidades');
      }
      if (stockMinimo < 0) {
        return _respuestaError('El stock mínimo no puede ser negativo');
      }
      if (stockMinimo > stockMaximo) {
        return _respuestaError('El stock mínimo no puede ser mayor al stock máximo');
      }
      
      final producto = Producto(
        id: '',
        nombre: data['nombre'] as String? ?? '',
        tipo: TipoInventarioExtension.fromString(data['tipo'] as String? ?? 'Producto'),
        clasificacion: data['clasificacion'] as String? ?? '',
        descripcion: data['descripcion'] as String? ?? '',
        sku: data['sku'] as String? ?? '',
        precio_compra: (data['precio_compra'] as num?)?.toDouble() ?? 0,
        precio_venta: (data['precio_venta'] as num?)?.toDouble() ?? 0,
        stock: (data['stock'] as num?)?.toInt() ?? 0,
        stock_minimo: (data['stock_minimo'] as num?)?.toInt() ?? 0,
        stock_maximo: (data['stock_maximo'] as num?)?.toInt() ?? 0,
        id_proveedor: data['id_proveedor'] as String?,
        ultima_actualizacion: DateTime.now(),
      );
      
      final productoCreado = await _repository.crearProducto(producto);
      
      return _respuestaExitosa({
        'id': productoCreado.id,
        'mensaje': 'Producto creado exitosamente',
      });
    } catch (e) {
      return _respuestaError('Error al crear producto: $e');
    }
  }
  
  Future<String> actualizarProducto(String id, Map<String, dynamic> data) async {
    try {
      final productoExistente = await _repository.obtenerProductoPorId(id);
      
      if (productoExistente == null) {
        return _respuestaError('Producto no encontrado');
      }
      
      final stock = (data['stock'] as num?)?.toInt() ?? productoExistente.stock;
      final stockMaximo = (data['stock_maximo'] as num?)?.toInt() ?? productoExistente.stock_maximo;
      final stockMinimo = (data['stock_minimo'] as num?)?.toInt() ?? productoExistente.stock_minimo;
      
      if (stock > 999) {
        return _respuestaError('El stock no puede exceder 999 unidades');
      }
      if (stockMaximo > 999) {
        return _respuestaError('El stock maximo no puede exceder 999 unidades');
      }
      if (stockMinimo < 0) {
        return _respuestaError('El stock minimo no puede ser negativo');
      }
      if (stockMinimo > stockMaximo) {
        return _respuestaError('El stock minimo no puede ser mayor al stock maximo');
      }
      
      final producto = Producto(
        id: id,
        nombre: data['nombre'] as String? ?? productoExistente.nombre,
        tipo: TipoInventarioExtension.fromString(data['tipo'] as String? ?? productoExistente.tipo.valor),
        clasificacion: data['clasificacion'] as String? ?? productoExistente.clasificacion,
        descripcion: data['descripcion'] as String? ?? productoExistente.descripcion,
        sku: data['sku'] as String? ?? productoExistente.sku,
        precio_compra: (data['precio_compra'] as num?)?.toDouble() ?? productoExistente.precio_compra,
        precio_venta: (data['precio_venta'] as num?)?.toDouble() ?? productoExistente.precio_venta,
        stock: (data['stock'] as num?)?.toInt() ?? productoExistente.stock,
        stock_minimo: (data['stock_minimo'] as num?)?.toInt() ?? productoExistente.stock_minimo,
        stock_maximo: (data['stock_maximo'] as num?)?.toInt() ?? productoExistente.stock_maximo,
        id_proveedor: data['id_proveedor'] as String? ?? productoExistente.id_proveedor,
        ultima_actualizacion: DateTime.now(),
      );
      
      await _repository.actualizarProducto(producto);
      
      return _respuestaExitosa({'mensaje': 'Producto actualizado exitosamente'});
    } catch (e) {
      return _respuestaError('Error al actualizar producto: $e');
    }
  }
  
  Future<String> entradaStock(String id, int cantidad, {String? motivo}) async {
    try {
      final producto = await _repository.obtenerProductoPorId(id);
      
      if (producto == null) {
        return _respuestaError('Producto no encontrado');
      }
      
      final nuevoStock = producto.stock + cantidad;
      
      if (nuevoStock > 999) {
        return _respuestaError('El stock no puede exceder 999 unidades. Stock actual: ${producto.stock}, intento: +$cantidad');
      }
      
      final resultado = await _repository.actualizarStock(id, nuevoStock);
      
      if (resultado) {
        return _respuestaExitosa({
          'mensaje': 'Stock agregado exitosamente',
          'stock_anterior': producto.stock,
          'stock_nuevo': nuevoStock,
        });
      }
      
      return _respuestaError('No se pudo actualizar el stock');
    } catch (e) {
      return _respuestaError('Error al agregar stock: $e');
    }
  }
  
  Future<String> salidaStock(String id, int cantidad, {String? motivo}) async {
    try {
      final producto = await _repository.obtenerProductoPorId(id);
      
      if (producto == null) {
        return _respuestaError('Producto no encontrado');
      }
      
      if (producto.stock < cantidad) {
        return _respuestaError('Stock insuficiente. Stock actual: ${producto.stock}');
      }
      
      final nuevoStock = producto.stock - cantidad;
      
      final resultado = await _repository.actualizarStock(id, nuevoStock);
      
      if (resultado) {
        return _respuestaExitosa({
          'mensaje': 'Stock reducido exitosamente',
          'stock_anterior': producto.stock,
          'stock_nuevo': nuevoStock,
        });
      }
      
      return _respuestaError('No se pudo actualizar el stock');
    } catch (e) {
      return _respuestaError('Error al reducir stock: $e');
    }
  }
  
  Future<String> eliminarProducto(String id) async {
    try {
      final resultado = await _repository.eliminarProducto(id);
      
      if (resultado) {
        return _respuestaExitosa({'mensaje': 'Producto eliminado exitosamente'});
      }
      
      return _respuestaError('No se pudo eliminar el producto');
    } catch (e) {
      return _respuestaError('Error al eliminar producto: $e');
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
