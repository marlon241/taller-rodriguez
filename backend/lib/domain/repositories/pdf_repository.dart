import 'dart:typed_data';
import '../entities/pdf_data.dart';

abstract class PdfRepository {
  Stream<Uint8List> generarFacturaPdf(PdfData pdfData);
}