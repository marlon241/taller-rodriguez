import '../entities/vehiculo.dart';

abstract class VehiculoRepository {
  Stream<List<Vehiculo>> obtenerVehiculos();
  
  Stream<List<Vehiculo>> obtenerVehiculosPorCliente(int idCliente);
  
  Future<Vehiculo?> obtenerVehiculoPorId(int id);
  
  Future<Vehiculo> crearVehiculo(Vehiculo vehiculo);
  
  Future<Vehiculo> actualizarVehiculo(Vehiculo vehiculo);
  
  Future<bool> eliminarVehiculo(int id);
  
  Stream<List<Vehiculo>> buscarVehiculos(String query);
}