import 'dart:typed_data';
import '../entities/pdf_data.dart';
import '../repositories/pdf_repository.dart';

class GenerarFacturaPdf {
  final PdfRepository repository;

  GenerarFacturaPdf(this.repository);

  Stream<Uint8List> call(PdfData pdfData) {
    return repository.generarFacturaPdf(pdfData);
  }
}