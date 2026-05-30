import 'dart:async';
import '../../domain/entities/empleado.dart';
import '../../domain/repositories/empleado_repository.dart';
import '../datasources/supabase_datasource.dart';

class EmpleadoRepositoryImpl implements EmpleadoRepository {
  final SupabaseDataSource _dataSource;

  final _empleadosController = StreamController<List<Empleado>>.broadcast();

  EmpleadoRepositoryImpl(this._dataSource);

  @override
  Stream<List<Empleado>> obtenerEmpleados() {
    _cargarEmpleados();
    return _empleadosController.stream;
  }

  Future<void> _cargarEmpleados() async {
    try {
      final datos = await _dataSource.select(
        'empleados',
        filtros: 'estado=eq.true',
        orderBy: 'nombre.asc',
      );

      final empleados = datos.map((json) => Empleado.fromJson(json)).toList();
      _empleadosController.add(empleados);
    } catch (e) {
      _empleadosController.addError(e);
    }
  }

  @override
  Future<Empleado?> obtenerEmpleadoPorId(int id) async {
    try {
      final datos = await _dataSource.select(
        'empleados',
        filtros: 'id=eq.$id',
      );

      if (datos.isEmpty) return null;
      return Empleado.fromJson(datos.first);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Empleado> crearEmpleado(Empleado empleado) async {
    final datos = await _dataSource.insert('empleados', empleado.toJson());
    _cargarEmpleados();
    return Empleado.fromJson(datos);
  }

  @override
  Future<Empleado> actualizarEmpleado(Empleado empleado) async {
    await _dataSource.update('empleados', empleado.toJson(), 'id=eq.${empleado.id}');
    _cargarEmpleados();
    return empleado;
  }

  @override
  Future<bool> eliminarEmpleado(int id) async {
    final resultado = await _dataSource.update(
      'empleados',
      {'estado': false},
      'id=eq.$id',
    );
    _cargarEmpleados();
    return resultado.isNotEmpty;
  }

  @override
  Stream<List<Empleado>> buscarEmpleados(String query) {
    _buscarEmpleados(query);
    return _empleadosController.stream;
  }

  Future<void> _buscarEmpleados(String query) async {
    try {
      final datos = await _dataSource.select(
        'empleados',
        filtros: 'estado=eq.true&or(nombre.ilike.*$query*,dui.ilike.*$query*,cargo.ilike.*$query*)',
        orderBy: 'nombre.asc',
      );

      final empleados = datos.map((json) => Empleado.fromJson(json)).toList();
      _empleadosController.add(empleados);
    } catch (e) {
      _empleadosController.addError(e);
    }
  }

  void dispose() {
    _empleadosController.close();
  }
}
