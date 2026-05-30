import '../entities/empleado.dart';

abstract class EmpleadoRepository {
  Stream<List<Empleado>> obtenerEmpleados();

  Future<Empleado?> obtenerEmpleadoPorId(int id);

  Future<Empleado> crearEmpleado(Empleado empleado);

  Future<Empleado> actualizarEmpleado(Empleado empleado);

  Future<bool> eliminarEmpleado(int id);

  Stream<List<Empleado>> buscarEmpleados(String query);
}
