import '../entities/factura_pdf.dart';

abstract class FacturaPdfRepository {
  Future<FacturaPdf?> obtenerFacturaParaPdf(int idFactura);
}