import '../entities/producto.dart';

abstract class InventarioRepository {
  Stream<List<Producto>> obtenerInventario();

  Future<Producto?> obtenerProductoPorId(String id);

  Stream<List<Producto>> obtenerProductos();

  Stream<List<Producto>> obtenerServicios();

  Stream<List<Producto>> buscarInventario(
    String query, {
    String? idProveedor,
    String? clasificacion,
    String? ordenStock,
  });

  Future<Producto> crearProducto(Producto producto);

  Future<Producto> actualizarProducto(Producto producto);

  Future<bool> actualizarStock(String id, int nuevaCantidad);

  Future<bool> restarStock(String id, int cantidad);

  Future<int> obtenerStockProducto(String id);

  Future<bool> eliminarProducto(String id);
}