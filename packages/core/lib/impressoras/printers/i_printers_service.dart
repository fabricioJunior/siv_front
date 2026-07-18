import 'dart:typed_data';

abstract class IPrintersService {
  List<Impressora> getAvailablePrinters();
  Future<bool> printZpl(Impressora printer, String zplCommands);
  Future<bool> printPdf(
    Impressora printer,
    Uint8List pdfBytes, {
    String docName = 'Documento',
  });

  /// Envia bytes crus (ex: comandos ESC/POS) direto pra impressora, sem
  /// passar por spool de PDF -- usado por impressoras termicas que aceitam
  /// impressao raw (mais rapida e sem depender de driver PDF).
  Future<bool> printRawBytes(
    Impressora printer,
    Uint8List bytes, {
    String docName = 'Documento',
  });
}

class Impressora {
  final String name;
  final String model;
  final String location;
  final bool isAvailable;

  Impressora({
    required this.name,
    required this.model,
    required this.location,
    required this.isAvailable,
  });
}
