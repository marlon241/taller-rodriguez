import '../domain/entities/empleado.dart';
import '../domain/entities/administrador.dart';
import '../domain/repositories/auth_repository.dart';
import 'datasources/supabase_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Administrador?> loginAdmin(String nombre, String contrasena) async {
    try {
      final resultado = await _dataSource.select(
        'administrador',
        filtros: 'nombre=eq.$nombre&contrasena=eq.$contrasena',
      );
      if (resultado.isEmpty) return null;
      return Administrador.fromJson(resultado.first);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Empleado?> loginEmpleado(String dui, String contrasena) async {
    try {
      final resultado = await _dataSource.select(
        'empleados',
        filtros: 'dui=eq.$dui&contrasena=eq.$contrasena&estado=eq.true',
      );
      if (resultado.isEmpty) return null;
      return Empleado.fromJson(resultado.first);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> existeAdministrador() async {
    try {
      final resultado = await _dataSource.select('administrador');
      return resultado.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Administrador> registrarAdmin(String nombre, String contrasena) async {
    final resultado = await _dataSource.insert('administrador', {
      'nombre': nombre,
      'contrasena': contrasena,
    });
    return Administrador.fromJson(resultado);
  }
}