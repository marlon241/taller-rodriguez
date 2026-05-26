import '../entities/proveedor.dart';

abstract class ProveedorRepository {
  Stream<List<Proveedor>> obtenerProveedores();

  Future<Proveedor?> obtenerProveedorPorId(int id);

  Future<Proveedor> crearProveedor(Proveedor proveedor);

  Future<Proveedor> actualizarProveedor(Proveedor proveedor);

  Future<bool> eliminarProveedor(int id);
  
  Future<bool> tieneInventario(int id);
  
  Future<bool> tieneFacturas(int id);

  Stream<List<Proveedor>> buscarProveedores(String query);
}