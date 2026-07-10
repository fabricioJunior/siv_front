import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:core/equals.dart';

class DocumentoFiscalDto extends Equatable implements DocumentoFiscal {
  @override
  final int id;
  @override
  final int empresaId;
  @override
  final int romaneioId;
  @override
  final int? pedidoId;
  @override
  final String acao;
  @override
  final String tipoDocumento;
  @override
  final String status;
  @override
  final String provider;
  @override
  final String? chaveAcesso;
  @override
  final String? protocolo;
  @override
  final String? erroMensagem;
  @override
  final int tentativas;
  @override
  final int maxTentativas;
  @override
  final String? pessoaNome;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final Map<String, dynamic>? payload;
  @override
  final dynamic respostaGateway;

  const DocumentoFiscalDto({
    required this.id,
    required this.empresaId,
    required this.romaneioId,
    this.pedidoId,
    required this.acao,
    required this.tipoDocumento,
    required this.status,
    required this.provider,
    this.chaveAcesso,
    this.protocolo,
    this.erroMensagem,
    required this.tentativas,
    required this.maxTentativas,
    this.pessoaNome,
    this.createdAt,
    this.updatedAt,
    this.payload,
    this.respostaGateway,
  });

  factory DocumentoFiscalDto.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    final pessoaNome = payload is Map ? payload['pessoaNome'] as String? : null;
    return DocumentoFiscalDto(
      id: json['id'] as int,
      empresaId: json['empresaId'] as int,
      romaneioId: json['romaneioId'] as int,
      pedidoId: json['pedidoId'] as int?,
      acao: json['acao'] as String,
      tipoDocumento: json['tipoDocumento'] as String,
      status: json['status'] as String,
      provider: json['provider'] as String,
      chaveAcesso: json['chaveAcesso'] as String?,
      protocolo: json['protocolo'] as String?,
      erroMensagem: json['erroMensagem'] as String?,
      tentativas: (json['tentativas'] as num?)?.toInt() ?? 0,
      maxTentativas: (json['maxTentativas'] as num?)?.toInt() ?? 5,
      pessoaNome: pessoaNome,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
      payload: payload is Map<String, dynamic> ? payload : null,
      respostaGateway: json['respostaGateway'],
    );
  }

  @override
  List<Object?> get props => [id, status, tentativas];
}

class DocumentoFiscalEventoDto extends Equatable implements DocumentoFiscalEvento {
  @override final int id;
  @override final int documentoFiscalId;
  @override final int tentativa;
  @override final bool sucesso;
  @override final String? externalId;
  @override final String? erroMensagem;
  @override final Map<String, dynamic>? payload;
  @override final dynamic resposta;
  @override final String? requestUrl;
  @override final Map<String, dynamic>? requestBody;
  @override final DateTime? criadoEm;

  const DocumentoFiscalEventoDto({
    required this.id,
    required this.documentoFiscalId,
    required this.tentativa,
    required this.sucesso,
    this.externalId,
    this.erroMensagem,
    this.payload,
    this.resposta,
    this.requestUrl,
    this.requestBody,
    this.criadoEm,
  });

  factory DocumentoFiscalEventoDto.fromJson(Map<String, dynamic> json) =>
      DocumentoFiscalEventoDto(
        id: json['id'] as int,
        documentoFiscalId: json['documentoFiscalId'] as int,
        tentativa: (json['tentativa'] as num).toInt(),
        sucesso: (json['sucesso'] as bool?) ?? false,
        externalId: json['externalId'] as String?,
        erroMensagem: json['erroMensagem'] as String?,
        payload: json['payload'] as Map<String, dynamic>?,
        resposta: json['resposta'],
        requestUrl: json['requestUrl'] as String?,
        requestBody: json['requestBody'] as Map<String, dynamic>?,
        criadoEm: json['criadoEm'] != null
            ? DateTime.tryParse(json['criadoEm'] as String)
            : null,
      );

  @override
  List<Object?> get props => [id, tentativa, sucesso];
}

class DocumentoFiscalDetalheDto extends Equatable implements DocumentoFiscalDetalhe {
  @override final DocumentoFiscal documento;
  @override final List<DocumentoFiscalEvento> eventos;

  const DocumentoFiscalDetalheDto({required this.documento, required this.eventos});

  factory DocumentoFiscalDetalheDto.fromJson(Map<String, dynamic> json) =>
      DocumentoFiscalDetalheDto(
        documento: DocumentoFiscalDto.fromJson(json),
        eventos: (json['eventos'] as List<dynamic>? ?? [])
            .map((e) => DocumentoFiscalEventoDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [documento, eventos];
}

class EmpresaIntegracaoFiscalDto extends Equatable implements EmpresaIntegracaoFiscal {
  @override
  final int? id;
  @override
  final int? empresaId;
  @override
  final String provider;
  @override
  final bool ativo;
  @override
  final Map<String, dynamic>? configuracao;

  const EmpresaIntegracaoFiscalDto({
    this.id,
    this.empresaId,
    required this.provider,
    required this.ativo,
    this.configuracao,
  });

  factory EmpresaIntegracaoFiscalDto.fromJson(Map<String, dynamic> json) {
    return EmpresaIntegracaoFiscalDto(
      id: json['id'] as int?,
      empresaId: json['empresaId'] as int?,
      provider: (json['provider'] as String?) ?? 'noop',
      ativo: (json['ativo'] as bool?) ?? true,
      configuracao: json['configuracao'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'ativo': ativo,
        if (configuracao != null) 'configuracao': configuracao,
      };

  @override
  List<Object?> get props => [id, provider, ativo];
}
