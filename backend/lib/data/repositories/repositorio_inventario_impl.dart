import 'dart:async';
import '../../domain/entities/producto.dart';
import '../../domain/repositories/inventario_repository.dart';
import '../datasources/supabase_datasource.dart';

class InventarioRepositoryImpl implements InventarioRepository {
  final SupabaseDataSource _dataSource;
  
  final _inventarioController = StreamController<List<Producto>>.broadcast();
  
  InventarioRepositoryImpl(this._dataSource);
  
  @override
  Stream<List<Producto>> obtenerInventario() {
    _cargarInventario();
    return _inventarioController.stream;
  }
  
  Future<void> _cargarInventario() async {
    try {
      final datos = await _dataSource.select('inventario', orderBy: 'id.asc');
      final productos = datos
          .map((json) => Producto.fromJson(json['id'].toString(), json))
          .toList();
      _inventarioController.add(productos);
    } catch (e) {
      _inventarioController.addError(e);
    }
  }
  
  @override
  Future<Producto?> obtenerProductoPorId(String id) async {
    try {
      final datos = await _dataSource.select('inventario', filtros: 'id=eq.$id');
      if (datos.isEmpty) return null;
      return Producto.fromJson(datos.first['id'].toString(), datos.first);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Stream<List<Producto>> obtenerProductos() {
    _cargarProductos();
    return _inventarioController.stream;
  }
  
  Future<void> _cargarProductos() async {
    try {
      final datos = await _dataSource.select(
        'inventario',
        filtros: 'estado=eq.true&tipo=eq.Producto&stock=gt.0',
      );
      final productos = datos
          .map((json) => Producto.fromJson(json['id'].toString(), json))
          .toList();
      _inventarioController.add(productos);
    } catch (e) {
      _inventarioController.addError(e);
    }
  }
  
  @override
  Stream<List<Producto>> obtenerServicios() {
    _cargarServicios();
    return _inventarioController.stream;
  }
  
  Future<void> _cargarServicios() async {
    try {
      final datos = await _dataSource.select(
        'inventario',
        filtros: 'estado=eq.true&tipo=eq.Servicio',
      );
      final productos = datos
          .map((json) => Producto.fromJson(json['id'].toString(), json))
          .toList();
      _inventarioController.add(productos);
    } catch (e) {
      _inventarioController.addError(e);
    }
  }
  
  @override
  Stream<List<Producto>> buscarInventario(
    String query, {
    String? idProveedor,
    String? clasificacion,
    String? ordenStock,
    String? ordenTipo,
  }) {
    _buscarInventario(
      query,
      idProveedor: idProveedor,
      clasificacion: clasificacion,
      ordenStock: ordenStock,
      ordenTipo: ordenTipo,
    );
    return _inventarioController.stream;
  }

  Future<void> _buscarInventario(
    String query, {
    String? idProveedor,
    String? clasificacion,
    String? ordenStock,
    String? ordenTipo,
  }) async {
    try {
      var filtros = '';
      var primero = true;

      if (query.isNotEmpty) {
        filtros += firstCondition(primero, 'or=(nombre.ilike.%25$query%25,sku.ilike.%25$query%25)');
        primero = false;
      }
      if (idProveedor != null && idProveedor.isNotEmpty) {
        filtros += firstCondition(primero, 'id_proveedor=eq.$idProveedor');
        primero = false;
      }
      if (clasificacion != null && clasificacion.isNotEmpty) {
        filtros += firstCondition(primero, 'clasificacion=eq.$clasificacion');
        primero = false;
      }

      String? orden;
      if (ordenStock != null && ordenTipo != null) {
        orden = 'tipo.${ordenTipo},stock.${ordenStock}';
      } else if (ordenStock != null) {
        orden = 'stock.${ordenStock}';
      } else if (ordenTipo != null) {
        orden = 'tipo.${ordenTipo}';
      }

      final datos = await _dataSource.select('inventario', filtros: filtros, orderBy: orden);
      final productos = datos
          .map((json) => Producto.fromJson(json['id'].toString(), json))
          .toList();
      _inventarioController.add(productos);
    } catch (e) {
      _inventarioController.addError(e);
    }
  }

  String firstCondition(bool primero, String condicion) {
    return primero ? condicion : '&$condicion';
  }
  
  @override
  Future<bool> actualizarStock(String id, int nuevaCantidad) async {
    try {
      await _dataSource.update(
        'inventario',
        {
          'stock': nuevaCantidad,
          'ultima_actualizacion': DateTime.now().toIso8601String(),
        },
        'id=eq.$id',
      );
      _cargarInventario();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> restarStock(String id, int cantidad) async {
    try {
      return await restarStockProducto(id, cantidad);
    } catch (e) {
      return false;
    }
  }

  Future<bool> restarStockProducto(String id, int cantidad) async {
    final producto = await obtenerProductoPorId(id);
    if (producto == null) return false;
    if (!producto.esProducto) return true;

    final stockActual = await obtenerStockProducto(id);
    final nuevoStock = stockActual - cantidad;

    if (nuevoStock < 0) {
      return false;
    }

    await _dataSource.update(
      'inventario',
      {
        'stock': nuevoStock,
        'ultima_actualizacion': DateTime.now().toIso8601String(),
      },
      'id=eq.$id',
    );
    _cargarInventario();
    return true;
  }

  Future<bool> restarStockServicio(String id, int cantidad) async {
    return true;
  }

  @override
  Future<int> obtenerStockProducto(String id) async {
    try {
      final datos = await _dataSource.select('inventario', filtros: 'id=eq.$id');
      if (datos.isEmpty) return 0;
      final stock = datos.first['stock'];
      if (stock == null) return 0;
      if (stock is int) return stock;
      if (stock is double) return stock.toInt();
      return int.tryParse(stock.toString()) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<Producto> crearProducto(Producto producto) async {
    final datos = await _dataSource.insert('inventario', producto.toJson());
    _cargarInventario();
    return Producto.fromJson(datos['id'].toString(), datos);
  }

  @override
  Future<Producto> actualizarProducto(Producto producto) async {
    await _dataSource.update('inventario', producto.toJson(), 'id=eq.${producto.id}');
    _cargarInventario();
    return producto;
  }

  @override
  Future<bool> eliminarProducto(String id) async {
    try {
      await _dataSource.delete('inventario', 'id=eq.$id');
      _cargarInventario();
      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _inventarioController.close();
  }
}