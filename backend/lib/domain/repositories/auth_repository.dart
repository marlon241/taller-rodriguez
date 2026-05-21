import '../entities/empleado.dart';
import '../entities/administrador.dart';

abstract class AuthRepository {
  Future<Administrador?> loginAdmin(String nombre, String contrasena);
  
  Future<Empleado?> loginEmpleado(String dui, String contrasena);
  
  Future<bool> existeAdministrador();
  
  Future<Administrador> registrarAdmin(String nombre, String contrasena);
}