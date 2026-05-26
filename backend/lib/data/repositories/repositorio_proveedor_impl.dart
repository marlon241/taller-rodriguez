import 'dart:async';
import '../../domain/entities/proveedor.dart';
import '../../domain/repositories/proveedor_repository.dart';
import '../datasources/supabase_datasource.dart';

class ProveedorRepositoryImpl implements ProveedorRepository {
  final SupabaseDataSource _dataSource;

  final _proveedoresController = StreamController<List<Proveedor>>.broadcast();

  ProveedorRepositoryImpl(this._dataSource);

  @override
  Stream<List<Proveedor>> obtenerProveedores() {
    _cargarProveedores();
    return _proveedoresController.stream;
  }

  Future<void> _cargarProveedores() async {
    try {
      final datos = await _dataSource.select(
        'proveedores',
        orderBy: 'nombre.asc',
      );

      final proveedores = datos.map((json) => Proveedor.fromJson(json)).toList();
      _proveedoresController.add(proveedores);
    } catch (e) {
      _proveedoresController.addError(e);
    }
  }

  @override
  Future<Proveedor?> obtenerProveedorPorId(int id) async {
    try {
      final datos = await _dataSource.select(
        'proveedores',
        filtros: 'id=eq.$id',
      );

      if (datos.isEmpty) return null;
      return Proveedor.fromJson(datos.first);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Proveedor> crearProveedor(Proveedor proveedor) async {
    final datos = await _dataSource.insert('proveedores', proveedor.toJson());
    _cargarProveedores();
    return Proveedor.fromJson(datos);
  }

  @override
  Future<Proveedor> actualizarProveedor(Proveedor proveedor) async {
    await _dataSource.update('proveedores', proveedor.toJson(), 'id=eq.${proveedor.id}');
    _cargarProveedores();
    return proveedor;
  }

  @override
  Future<bool> eliminarProveedor(int id) async {
    final resultado = await _dataSource.delete('proveedores', 'id=eq.$id');
    _cargarProveedores();
    return resultado;
  }
  
  @override
  Future<bool> tieneInventario(int id) async {
    try {
      final datos = await _dataSource.select(
        'inventario',
        filtros: 'id_proveedor=eq.$id',
        limit: 1,
      );
      return datos.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> tieneFacturas(int id) async {
    try {
      final datos = await _dataSource.select(
        'facturacion',
        filtros: 'id_cliente=eq.$id',
        limit: 1,
      );
      return datos.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<List<Proveedor>> buscarProveedores(String query) {
    _buscarProveedores(query);
    return _proveedoresController.stream;
  }

  Future<void> _buscarProveedores(String query) async {
    try {
      final datos = await _dataSource.select(
        'proveedores',
        filtros: 'or(nombre.ilike.*$query*,nit.ilike.*$query*)',
        orderBy: 'nombre.asc',
      );

      final proveedores = datos.map((json) => Proveedor.fromJson(json)).toList();
      _proveedoresController.add(proveedores);
    } catch (e) {
      _proveedoresController.addError(e);
    }
  }

  void dispose() {
    _proveedoresController.close();
  }
}