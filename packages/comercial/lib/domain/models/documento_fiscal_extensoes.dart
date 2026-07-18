import 'package:comercial/domain/models/documento_fiscal.dart';

/// URL da DANFE (nota fiscal em PDF) hospedada pelo gateway fiscal (ex:
/// Web Mania), extraida de `respostaGateway`. Usada tanto na tela de
/// detalhe do documento fiscal quanto na impressao da nota.
extension DocumentoFiscalDanfeX on DocumentoFiscal {
  String? get urlDanfe {
    final resposta = respostaGateway;
    if (resposta is Map) {
      final url = resposta['danfe'];
      return url is String && url.isNotEmpty ? url : null;
    }
    return null;
  }
}
