import 'dart:typed_data';

import 'package:comercial/domain/models/danfe_mapper.dart';
import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/models/romaneio.dart';
import 'package:comercial/presentation/relatorios/danfe/danfe_pdf_renderer.dart';
import 'package:core/pdf.dart' show PdfPageFormat;

/// Gera o PDF da nota fiscal (DANFE) para impressao em impressora termica
/// 58mm/80mm.
///
/// Renderiza sempre localmente a partir de `documento.payload`/`respostaGateway`
/// (ver `presentation/relatorios/danfe/`) -- nao depende de baixar a DANFE
/// pronta do gateway fiscal (Web Mania), que se mostrou indisponivel/lento
/// pra esse fluxo. [erroServidor] fica sempre `null`; mantido no retorno so
/// pra nao quebrar os call sites que ja tratam esse par.
class NotaFiscalPdfExporter {
  NotaFiscalPdfExporter._();

  static Future<({Uint8List bytes, Object? erroServidor})> gerarBytes(
    DocumentoFiscal documento, {
    Romaneio? romaneio,
    PdfPageFormat pageFormat = PdfPageFormat.roll80,
  }) async {
    final dados = construirDanfeLayoutData(documento, romaneio: romaneio);
    final bytes = await DanfePdfRenderer.render(dados, pageFormat: pageFormat);
    return (bytes: bytes, erroServidor: null);
  }
}
