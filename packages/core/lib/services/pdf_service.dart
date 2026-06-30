import 'dart:typed_data';
import 'package:printing/printing.dart';

class PdfService {
  PdfService._();

  static Future<void> compartilhar(Uint8List bytes, String filename) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}
