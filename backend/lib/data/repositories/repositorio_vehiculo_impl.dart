import 'dart:async';
import '../../domain/entities/vehiculo.dart';
import '../../domain/repositories/vehiculo_repository.dart';
import '../datasources/supabase_datasource.dart';

class VehiculoRepositoryImpl implements VehiculoRepository {
  final SupabaseDataSource _dataSource;
  
  final _vehiculosController = StreamController<List<Vehiculo>>.broadcast();
  
  VehiculoRepositoryImpl(this._dataSource);
  
  @override
  Stream<List<Vehiculo>> obtenerVehiculos() {
    _cargarVehiculos();
    return _vehiculosController.stream;
  }
  
  Future<void> _cargarVehiculos() async {
    try {
      final datos = await _dataSource.select(
        'vehiculos',
        orderBy: 'fecha_ingreso.desc',
      );

      final vehiculos = datos.map((json) => Vehiculo.fromJson(json)).toList();
      _vehiculosController.add(vehiculos);
    } catch (e) {
      _vehiculosController.addError(e);
    }
  }

  Future<Map<String, dynamic>?> _obtenerDatosCliente(int idCliente) async {
    try {
      final datos = await _dataSource.select(
        'clientes',
        filtros: 'id=eq.$idCliente',
      );
      if (datos.isEmpty) return null;
      return datos.first;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Stream<List<Vehiculo>> obtenerVehiculosPorCliente(int idCliente) {
    _cargarVehiculosPorCliente(idCliente);
    return _vehiculosController.stream;
  }
  
  Future<void> _cargarVehiculosPorCliente(int idCliente) async {
    try {
      final datos = await _dataSource.select(
        'vehiculos',
        filtros: 'id_cliente=eq.$idCliente',
        orderBy: 'fecha_ingreso.desc',
      );
      
      final vehiculos = datos.map((json) => Vehiculo.fromJson(json)).toList();
      _vehiculosController.add(vehiculos);
    } catch (e) {
      _vehiculosController.addError(e);
    }
  }
  
  @override
  Future<Vehiculo?> obtenerVehiculoPorId(int id) async {
    try {
      final datos = await _dataSource.select(
        'vehiculos',
        filtros: 'id=eq.$id',
      );
      
      if (datos.isEmpty) return null;
      return Vehiculo.fromJson(datos.first);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<Vehiculo> crearVehiculo(Vehiculo vehiculo) async {
    final datos = await _dataSource.insert('vehiculos', vehiculo.toJson());
    _cargarVehiculos();
    return Vehiculo.fromJson(datos);
  }
  
  @override
  Future<Vehiculo> actualizarVehiculo(Vehiculo vehiculo) async {
    await _dataSource.update('vehiculos', vehiculo.toJson(), 'id=eq.${vehiculo.id}');
    _cargarVehiculos();
    return vehiculo;
  }
  
  @override
  Future<bool> eliminarVehiculo(int id) async {
    return await _dataSource.delete('vehiculos', 'id=eq.$id');
  }
  
  @override
  Stream<List<Vehiculo>> buscarVehiculos(String query) {
    _buscarVehiculos(query);
    return _vehiculosController.stream;
  }
  
  Future<void> _buscarVehiculos(String query) async {
    try {
      final datos = await _dataSource.select(
        'vehiculos',
        filtros: 'or(placa.ilike.*$query*,marca.ilike.*$query*,modelo.ilike.*$query*)',
        orderBy: 'fecha_ingreso.desc',
      );
      
      final vehiculos = datos.map((json) => Vehiculo.fromJson(json)).toList();
      _vehiculosController.add(vehiculos);
    } catch (e) {
      _vehiculosController.addError(e);
    }
  }
  
  void dispose() {
    _vehiculosController.close();
  }
}