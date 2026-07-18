import 'dart:typed_data';

import 'package:comercial/domain/data/repositories/i_integracao_fiscal_repository.dart';
import 'package:comercial/domain/models/danfe_mapper.dart';
import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/models/romaneio.dart';
import 'package:comercial/presentation/relatorios/danfe/danfe_pdf_renderer.dart';
import 'package:core/injecoes.dart';
import 'package:core/pdf.dart' show PdfPageFormat;

/// Gera/obtem o PDF da nota fiscal (DANFE) para impressao em impressora
/// termica 80mm.
///
/// Estrategia: baixa a DANFE ja pronta via [IIntegracaoFiscalRepository.baixarDanfe],
/// que faz o backend buscar o PDF direto no gateway fiscal (ex: Web Mania,
/// GET /danfe/{chave}/ autenticado com as credenciais do provider -- nunca
/// expostas ao app). Se a chamada falhar (nota nao emitida, gateway fora do
/// ar, erro de rede/servidor etc), monta um layout DANFE proprio (fallback,
/// ver `presentation/relatorios/danfe/`) a partir de `documento.payload`/
/// `respostaGateway` -- pra impressao nunca ficar bloqueada por
/// indisponibilidade do gateway fiscal -- mas devolve o erro original em
/// [erroServidor] pra quem chama poder avisar o usuario que o layout
/// impresso nao e o oficial.
class NotaFiscalPdfExporter {
  NotaFiscalPdfExporter._();

  static Future<({Uint8List bytes, Object? erroServidor})> gerarBytes(
    DocumentoFiscal documento, {
    Romaneio? romaneio,
    PdfPageFormat pageFormat = PdfPageFormat.roll80,
  }) async {
    try {
      final bytes = await sl<IIntegracaoFiscalRepository>().baixarDanfe(documento.id);
      return (bytes: bytes, erroServidor: null);
    } catch (erro) {
      return (
        bytes: await _gerarFallback(documento, romaneio: romaneio, pageFormat: pageFormat),
        erroServidor: erro,
      );
    }
  }

  static Future<Uint8List> _gerarFallback(
    DocumentoFiscal documento, {
    Romaneio? romaneio,
    required PdfPageFormat pageFormat,
  }) {
    final dados = construirDanfeLayoutData(documento, romaneio: romaneio);
    return DanfePdfRenderer.render(dados, pageFormat: pageFormat);
  }
}
