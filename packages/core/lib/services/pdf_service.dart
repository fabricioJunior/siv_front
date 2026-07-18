import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';

class PdfService {
  PdfService._();

  static Future<void> compartilhar(Uint8List bytes, String filename) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  /// Baixa bytes de um PDF a partir de uma URL externa (ex: DANFE gerada
  /// por um gateway fiscal). Retorna null se a URL nao respondeu com um
  /// PDF valido (erro de rede, 404, formato inesperado etc).
  static Future<Uint8List?> baixarPdf(String url) async {
    try {
      final resposta = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (resposta.statusCode != 200 || resposta.bodyBytes.isEmpty) {
        return null;
      }

      // PDF valido comeca com a assinatura "%PDF".
      final bytes = resposta.bodyBytes;
      final assinaturaValida = bytes.length > 4 &&
          bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46;

      return assinaturaValida ? bytes : null;
    } catch (_) {
      return null;
    }
  }
}
