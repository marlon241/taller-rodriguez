import 'dart:async';
import '../../domain/entities/cliente.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../datasources/supabase_datasource.dart';

class ClienteRepositoryImpl implements ClienteRepository {
  final SupabaseDataSource _dataSource;
  
  final _clientesController = StreamController<List<Cliente>>.broadcast();
  
  ClienteRepositoryImpl(this._dataSource);
  
  @override
  Stream<List<Cliente>> obtenerClientes() {
    _cargarClientes();
    return _clientesController.stream;
  }
  
  Future<void> _cargarClientes() async {
    try {
      final datos = await _dataSource.select(
        'clientes',
        filtros: 'estado=eq.true',
        orderBy: 'nombre.asc',
      );
      
      final clientes = datos.map((json) => Cliente.fromJson(json)).toList();
      _clientesController.add(clientes);
    } catch (e) {
      _clientesController.addError(e);
    }
  }
  
  @override
  Future<Cliente?> obtenerClientePorId(int id) async {
    try {
      final datos = await _dataSource.select(
        'clientes',
        filtros: 'id=eq.$id',
      );
      
      if (datos.isEmpty) return null;
      return Cliente.fromJson(datos.first);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<Cliente> crearCliente(Cliente cliente) async {
    final datos = await _dataSource.insert('clientes', cliente.toJson());
    _cargarClientes();
    return Cliente.fromJson(datos);
  }
  
  @override
  Future<Cliente> actualizarCliente(Cliente cliente) async {
    await _dataSource.update('clientes', cliente.toJson(), 'id=eq.${cliente.id}');
    _cargarClientes();
    return cliente;
  }
  
  @override
  Future<bool> eliminarCliente(int id) async {
    final resultado = await _dataSource.update(
      'clientes',
      {'estado': false},
      'id=eq.$id',
    );
    _cargarClientes();
    return resultado.isNotEmpty;
  }
  
  @override
  Stream<List<Cliente>> buscarClientes(String query) {
    _buscarClientes(query);
    return _clientesController.stream;
  }
  
  Future<void> _buscarClientes(String query) async {
    try {
      final datos = await _dataSource.select(
        'clientes',
        filtros: 'estado=eq.true&or(nombre.ilike.*$query*,dui.ilike.*$query*)',
        orderBy: 'nombre.asc',
      );
      
      final clientes = datos.map((json) => Cliente.fromJson(json)).toList();
      _clientesController.add(clientes);
    } catch (e) {
      _clientesController.addError(e);
    }
  }

  void dispose() {
    _clientesController.close();
  }
}