import 'dart:typed_data';

import 'package:core/impressoras/printers/i_printers_service.dart';

// ponytail: impressão no-op no web, sem alternativa via browser ainda.
class PrintersService implements IPrintersService {
  @override
  List<Impressora> getAvailablePrinters() => [];

  @override
  Future<bool> printZpl(Impressora printer, String zplCommands) =>
      Future.value(false);

  @override
  Future<bool> printPdf(
    Impressora printer,
    Uint8List pdfBytes, {
    String docName = 'Documento',
  }) =>
      Future.value(false);

  @override
  Future<bool> printRawBytes(
    Impressora printer,
    Uint8List bytes, {
    String docName = 'Documento',
  }) =>
      Future.value(false);
}
