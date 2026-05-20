import 'dart:async';
import '../../domain/entities/producto.dart';
import '../../domain/repositories/inventario_repository.dart';
import '../datasources/firebase_datasource.dart';

class InventarioRepositoryImpl implements InventarioRepository {
  final FirebaseDataSource _dataSource;
  
  final _inventarioController = StreamController<List<Producto>>.broadcast();
  
  InventarioRepositoryImpl(this._dataSource);
  
  @override
  Stream<List<Producto>> obtenerInventario() {
    _cargarInventario();
    return _inventarioController.stream;
  }
  
  Future<void> _cargarInventario() async {
    try {
      final datos = await _dataSource.getCollection('inventario');
      final productos = datos
          .where((doc) => _getBool(doc['estado']))
          .map((json) {
            final id = json['id']?.toString() ?? '';
            return Producto.fromJson(id, json);
          })
          .toList();
      _inventarioController.add(productos);
    } catch (e) {
      _inventarioController.addError(e);
    }
  }
  
  bool _getBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1 || value == true;
    return false;
  }
  
  String _getString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
  
  @override
  Future<Producto?> obtenerProductoPorId(String id) async {
    try {
      final datos = await _dataSource.getDocument('inventario', id);
      if (datos == null) return null;
      return Producto.fromJson(id, datos);
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
      final datos = await _dataSource.getCollection('inventario');
      final productos = datos
          .where((doc) => 
              _getBool(doc['estado']) && 
              _getString(doc['tipo']) == 'Producto' && 
              (doc['stock'] as int? ?? 0) > 0)
          .map((json) => Producto.fromJson(json['id']?.toString() ?? '', json))
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
      final datos = await _dataSource.getCollection('inventario');
      final productos = datos
          .where((doc) => _getBool(doc['estado']) && _getString(doc['tipo']) == 'Servicio')
          .map((json) => Producto.fromJson(json['id']?.toString() ?? '', json))
          .toList();
      _inventarioController.add(productos);
    } catch (e) {
      _inventarioController.addError(e);
    }
  }
  
  @override
  Stream<List<Producto>> buscarInventario(String query) {
    _buscarInventario(query);
    return _inventarioController.stream;
  }
  
  Future<void> _buscarInventario(String query) async {
    try {
      final datos = await _dataSource.getCollection('inventario');
      final productos = datos
          .where((doc) => 
              _getBool(doc['estado']) &&
              (_getString(doc['nombre']).toLowerCase().contains(query.toLowerCase()) ||
              _getString(doc['sku']).toLowerCase().contains(query.toLowerCase())))
          .map((json) => Producto.fromJson(json['id']?.toString() ?? '', json))
          .toList();
      _inventarioController.add(productos);
    } catch (e) {
      _inventarioController.addError(e);
    }
  }
  
  @override
  Future<bool> actualizarStock(String id, int nuevaCantidad) async {
    try {
      return await _dataSource.updateDocument('inventario', id, {
        'stock': nuevaCantidad,
        'ultima_actualizacion': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      return false;
    }
  }
  
  void dispose() {
    _inventarioController.close();
  }
}