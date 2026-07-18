import 'dart:typed_data';

import 'package:comercial/domain/models/danfe_mapper.dart';
import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/models/romaneio.dart';
import 'package:comercial/presentation/relatorios/danfe/danfe_esc_pos_renderer.dart';

/// Gera os bytes ESC/POS do DANFE (fallback local, mesmo layout logico do
/// `NotaFiscalPdfExporter`) -- pra impressoras termicas que aceitam envio
/// de comandos raw em vez de PDF (via `IPrintersService.printRawBytes`).
///
/// Diferente do caminho PDF, aqui nao ha DANFE oficial pronta pra baixar do
/// gateway fiscal (o gateway so devolve PDF) -- entao o layout local e o
/// unico disponivel pra essa via.
class NotaFiscalEscPosExporter {
  NotaFiscalEscPosExporter._();

  static Uint8List gerarBytes(
    DocumentoFiscal documento, {
    Romaneio? romaneio,
    DanfeLarguraPapel largura = DanfeLarguraPapel.mm80,
  }) {
    final dados = construirDanfeLayoutData(documento, romaneio: romaneio);
    return DanfeEscPosRenderer.render(dados, largura: largura);
  }
}
