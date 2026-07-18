import 'dart:developer';
import 'dart:io';

/// Encapsula a impressao de PDF em impressora termica ESC/POS compartilhada
/// via SMB no macOS -- o driver nativo do macOS para a Bematech MP-4200 HS
/// nao funciona (a impressora e ESC/POS, nao entende PostScript/raster
/// generico), entao o PDF e convertido e enviado via script Python externo
/// (`print_pdf.sh`), que renderiza as paginas, dithera pra 1-bit, gera os
/// comandos ESC/POS raster e manda pra fila CUPS correta.
class MacThermalPrintService {
  MacThermalPrintService._();

  static String get _scriptPath =>
      '${Platform.environment['HOME']}/bematech-print/print_pdf.sh';

  /// Envia o PDF em [pdfPath] para impressao via script externo. Retorna
  /// `true` se o script terminou com exit code 0.
  static Future<bool> printPdf(String pdfPath) async {
    try {
      final resultado = await Process.run(_scriptPath, [pdfPath]);
      if (resultado.exitCode != 0) {
        log('MacThermalPrintService: falha ao imprimir "$pdfPath" '
            '(exit ${resultado.exitCode}): ${resultado.stderr}');
        return false;
      }
      return true;
    } catch (e) {
      log('MacThermalPrintService: erro ao executar $_scriptPath: $e');
      return false;
    }
  }
}
