import 'dart:convert';
import 'dart:typed_data';

/// Alinhamento de texto suportado pelo comando ESC/POS `ESC a`.
enum EscPosAlinhamento { esquerda, centro, direita }

/// Monta uma sequencia de comandos ESC/POS (padrao usado pela maioria das
/// impressoras termicas) a partir de chamadas de alto nivel -- negrito,
/// alinhamento, texto, corte de papel e QR Code nativo (`GS ( k`).
///
/// Utilitario generico de baixo nivel (infra compartilhada, nao especifico
/// de nenhum documento). Layouts especificos (ex: DANFE) ficam em camadas
/// superiores, que usam este builder so para emitir os bytes finais.
class EscPosBuilder {
  final BytesBuilder _buffer = BytesBuilder();

  static const _esc = 0x1B;
  static const _gs = 0x1D;

  EscPosBuilder() {
    // ESC @ -- inicializa a impressora (limpa buffer/formatacao residual).
    _buffer.addByte(_esc);
    _buffer.addByte(0x40);
  }

  void alinhar(EscPosAlinhamento alinhamento) {
    final codigo = switch (alinhamento) {
      EscPosAlinhamento.esquerda => 0,
      EscPosAlinhamento.centro => 1,
      EscPosAlinhamento.direita => 2,
    };
    _buffer.addByte(_esc);
    _buffer.addByte(0x61);
    _buffer.addByte(codigo);
  }

  void negrito(bool ativo) {
    _buffer.addByte(_esc);
    _buffer.addByte(0x45);
    _buffer.addByte(ativo ? 1 : 0);
  }

  /// Fonte em dobro de largura/altura (`GS !`) -- usado em titulos de
  /// destaque (ex: nome fantasia no cabecalho).
  void fonteDupla(bool ativo) {
    _buffer.addByte(_gs);
    _buffer.addByte(0x21);
    _buffer.addByte(ativo ? 0x11 : 0x00);
  }

  /// Escreve uma linha de texto (com quebra `\n`). Usa CP850/Latin-1 --
  /// charset mais comum entre impressoras termicas ESC/POS nacionais.
  void texto(String linha) {
    _buffer.add(latin1.encode('$linha\n'));
  }

  void linhaEmBranco([int quantidade = 1]) {
    for (var i = 0; i < quantidade; i++) {
      _buffer.add(latin1.encode('\n'));
    }
  }

  /// QR Code nativo via `GS ( k` (padrao suportado pela maioria das
  /// impressoras termicas ESC/POS com modulo de QR embutido).
  void qrCode(String dado, {int tamanhoModulo = 4}) {
    final bytes = utf8.encode(dado);
    final tamanho = bytes.length + 3;
    final pL = tamanho % 256;
    final pH = tamanho ~/ 256;

    // Modelo do QR Code (modelo 2, padrao).
    _buffer.add([_gs, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00]);
    // Tamanho do modulo.
    _buffer.add([_gs, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, tamanhoModulo]);
    // Nivel de correcao de erro (48 = padrao).
    _buffer.add([_gs, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, 0x30]);
    // Armazena os dados do QR Code.
    _buffer.add([_gs, 0x28, 0x6B, pL, pH, 0x31, 0x50, 0x30]);
    _buffer.add(bytes);
    // Imprime o QR Code armazenado.
    _buffer.add([_gs, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30]);
  }

  void cortarPapel() {
    linhaEmBranco(3);
    _buffer.add([_gs, 0x56, 0x00]);
  }

  Uint8List build() => _buffer.toBytes();
}
