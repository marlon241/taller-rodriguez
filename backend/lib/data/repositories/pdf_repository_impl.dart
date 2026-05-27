import 'dart:typed_data';
import '../../domain/entities/pdf_data.dart';
import '../../domain/repositories/pdf_repository.dart';
import '../datasources/pdf_datasource.dart';

class PdfRepositoryImpl implements PdfRepository {
  final PdfDatasource datasource;

  PdfRepositoryImpl(this.datasource);

  @override
  Stream<Uint8List> generarFacturaPdf(PdfData pdfData) async* {
    final bytes = await datasource.generarPdf(FacturaPdfInput(pdfData));
    yield bytes;
  }
}