import '../entities/factura.dart';

abstract class FacturaRepository {
  Stream<List<Factura>> obtenerFacturas();
  
  Future<Factura?> obtenerFacturaPorId(int id);
  
  Stream<List<Factura>> obtenerFacturasPorCliente(int idCliente);
  
  Stream<List<Factura>> obtenerFacturasPorVehiculo(int idVehiculo);
  
  Future<Factura> crearFactura(Factura factura);
  
  Future<bool> eliminarFactura(int id);
}