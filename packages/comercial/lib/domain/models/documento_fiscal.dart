import 'package:core/equals.dart';

abstract class DocumentoFiscal implements Equatable {
  int get id;
  int get empresaId;
  int get romaneioId;
  int? get pedidoId;
  String get acao;
  String get tipoDocumento;
  String get status;
  String get provider;
  String? get chaveAcesso;
  String? get protocolo;
  String? get erroMensagem;
  int get tentativas;
  int get maxTentativas;
  String? get pessoaNome;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  Map<String, dynamic>? get payload;
  dynamic get respostaGateway;
  int? get ambiente;
}

/// tpAmb 2 = homologacao (SEFAZ), nota sem valor fiscal -- so o provider sefaz preenche `ambiente`.
extension DocumentoFiscalAmbiente on DocumentoFiscal {
  bool get emitidaEmHomologacao => ambiente == 2;
}

extension DocumentoFiscalPayload on DocumentoFiscal {
  double get valorLiquido => (payload?['valorLiquido'] as num?)?.toDouble() ?? 0;
  String? get pessoaDocumento => payload?['pessoaDocumento'] as String?;

  String get tipoDocumentoLabel => switch (tipoDocumento) {
        'nfe_venda' => 'Venda',
        'nfe_devolucao_venda' => 'Devolução de Venda',
        'nfe_devolucao_compra' => 'Devolução de Compra',
        'evento_cancelamento' => 'Cancelamento',
        _ => tipoDocumento,
      };

  /// Documento mascarado (`123***`) + nome, se ambos presentes; só um dos dois se só ele existir;
  /// "Sem cliente" se nenhum.
  String get clienteMascarado {
    final doc = pessoaDocumento;
    final nome = pessoaNome;
    if (doc != null && doc.length >= 3) {
      final mascara = '${doc.substring(0, 3)}***';
      return nome != null ? '$mascara — $nome' : mascara;
    }
    return nome ?? 'Sem cliente';
  }
}

abstract class DocumentoFiscalFiltros {
  int? get romaneioId;
  int? get pedidoId;
  String? get cliente;
  String? get status;
  String? get formaPagamento;
  DateTime? get dataInicio;
  DateTime? get dataFim;
  int? get page;
  int? get limit;
}

abstract class DocumentoFiscalEvento implements Equatable {
  int get id;
  int get documentoFiscalId;
  int get tentativa;
  bool get sucesso;
  String? get externalId;
  String? get erroMensagem;
  Map<String, dynamic>? get payload;
  dynamic get resposta;
  String? get requestUrl;
  Map<String, dynamic>? get requestBody;
  DateTime? get criadoEm;
}

abstract class DocumentoFiscalDetalhe implements Equatable {
  DocumentoFiscal get documento;
  List<DocumentoFiscalEvento> get eventos;
}

abstract class EmpresaIntegracaoFiscal implements Equatable {
  int? get id;
  int? get empresaId;
  String get provider;
  bool get ativo;
  Map<String, dynamic>? get configuracao;
}
