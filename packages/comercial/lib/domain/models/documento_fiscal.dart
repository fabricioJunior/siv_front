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
