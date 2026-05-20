import '../entities/producto.dart';

abstract class InventarioRepository {
  Stream<List<Producto>> obtenerInventario();
  
  Future<Producto?> obtenerProductoPorId(String id);
  
  Stream<List<Producto>> obtenerProductos();
  
  Stream<List<Producto>> obtenerServicios();
  
  Stream<List<Producto>> buscarInventario(String query);
  
  Future<bool> actualizarStock(String id, int nuevaCantidad);
}