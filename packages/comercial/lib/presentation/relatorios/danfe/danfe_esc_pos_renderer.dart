import 'dart:typed_data';

import 'package:comercial/domain/models/danfe.dart';
import 'package:comercial/presentation/relatorios/danfe/danfe_layout.dart';
import 'package:comercial/presentation/relatorios/danfe/danfe_texto_wrap.dart';
import 'package:core/impressoras/printers/esc_pos_builder.dart';

/// Larguras usuais (em colunas de fonte monoespacada) pra impressao termica
/// ESC/POS -- 58mm ~= 32 colunas, 80mm ~= 48 colunas (fonte padrao "Font A").
enum DanfeLarguraPapel {
  mm58(32),
  mm80(48);

  final int colunas;
  const DanfeLarguraPapel(this.colunas);
}

/// Renderiza o DANFE em comandos ESC/POS a partir da mesma arvore de nodes
/// usada pelo renderer de PDF (`danfe_pdf_renderer.dart`).
class DanfeEscPosRenderer {
  DanfeEscPosRenderer._();

  /// Margem de seguranca (em colunas) subtraida da largura nominal do
  /// papel -- a largura util real de impressao costuma ser menor que a
  /// nominal (depende de fonte/driver de cada impressora), o que corta os
  /// ultimos caracteres de linhas que preenchem a coluna inteira (ex: valor
  /// alinhado a direita como "R$ 85,50" saindo cortado como "R$ 85").
  static const _margemSeguranca = 2;

  static Uint8List render(
    DanfeLayoutData dados, {
    DanfeLarguraPapel largura = DanfeLarguraPapel.mm80,
  }) {
    final builder = EscPosBuilder();
    final colunas = largura.colunas - _margemSeguranca;

    for (final node in construirDanfeNodes(dados)) {
      switch (node) {
        case DanfeTexto texto:
          builder.alinhar(_alinhamentoEscPos(texto.alinhamento));
          builder.negrito(texto.negrito);
          if (texto.escala > 1) builder.fonteDupla(true);
          for (final linha in quebrarLinhaDanfe(texto.texto, colunas)) {
            builder.texto(linha);
          }
          if (texto.escala > 1) builder.fonteDupla(false);
          builder.negrito(false);

        case DanfeLinhaDupla linha:
          builder.alinhar(EscPosAlinhamento.esquerda);
          builder.negrito(linha.negrito);
          for (final l in linhaComValorDireitaDanfe(linha.esquerda, linha.direita, colunas)) {
            builder.texto(l);
          }
          builder.negrito(false);

        case DanfeSeparador():
          builder.alinhar(EscPosAlinhamento.esquerda);
          builder.texto('-' * colunas);

        case DanfeEspaco espaco:
          builder.linhaEmBranco(espaco.linhas);

        case DanfeQrCode qr:
          builder.alinhar(EscPosAlinhamento.centro);
          builder.qrCode(qr.dado);
          builder.alinhar(EscPosAlinhamento.esquerda);
      }
    }

    builder.alinhar(EscPosAlinhamento.esquerda);
    builder.cortarPapel();
    return builder.build();
  }

  static EscPosAlinhamento _alinhamentoEscPos(DanfeAlinhamento alinhamento) => switch (alinhamento) {
        DanfeAlinhamento.esquerda => EscPosAlinhamento.esquerda,
        DanfeAlinhamento.centro => EscPosAlinhamento.centro,
        DanfeAlinhamento.direita => EscPosAlinhamento.direita,
      };

}
