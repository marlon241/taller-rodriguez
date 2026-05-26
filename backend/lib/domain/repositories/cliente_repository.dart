import '../entities/cliente.dart';

abstract class ClienteRepository {
  Stream<List<Cliente>> obtenerClientes();
  
  Future<Cliente?> obtenerClientePorId(int id);
  
  Future<Cliente> crearCliente(Cliente cliente);
  
  Future<Cliente> actualizarCliente(Cliente cliente);
  
  Future<bool> eliminarCliente(int id);
  
  Stream<List<Cliente>> buscarClientes(String query);
}