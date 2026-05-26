import '../entities/oferta.dart';

abstract class OfertaRepository {
  Stream<List<Oferta>> obtenerOfertasActivas();
  
  Stream<List<Oferta>> obtenerTodasLasOfertas();
  
  Future<Oferta?> obtenerOfertaPorId(int id);
  
  Future<Oferta?> obtenerOfertaPorProducto(String idProductoFirebase);
  
  Future<Oferta> crearOferta(Oferta oferta);
  
  Future<Oferta> actualizarOferta(Oferta oferta);
  
  Future<bool> eliminarOferta(int id);
  
  Future<bool> tieneFacturasAsociadas(int id);
}