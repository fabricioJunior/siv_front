import 'package:pagamentos/domain/models/pagamento_avulso.dart';

class PagamentoAvulsoDto implements PagamentoAvulso {
  @override
  final DateTime? criadoEm;

  @override
  final DateTime? atualizadoEm;

  @override
  final int? id;

  @override
  final int? empresaId;

  @override
  final int? usuarioId;

  @override
  final String provider;

  @override
  final String? status;

  @override
  final int amount;

  @override
  final String description;

  @override
  final String? urlDePagamento;

  @override
  final String? urlComprovante;

  @override
  final String? qrCodePix;

  @override
  final String? externalReference;

  @override
  final String idempotencyKey;

  @override
  final String? externalId;

  @override
  final Map<String, dynamic> metadata;

  @override
  final Map<String, dynamic> requisicaoGateway;

  @override
  final Map<String, dynamic> respostaGateway;

  @override
  final DateTime? pagoEm;

  @override
  final DateTime? canceladoEm;

  @override
  final String? motivoCancelamento;

  @override
  final PagamentoAvulsoCustomerDto customer;

  @override
  const PagamentoAvulsoDto({
    this.criadoEm,
    this.atualizadoEm,
    this.id,
    this.empresaId,
    this.usuarioId,
    required this.provider,
    this.status,
    required this.amount,
    required this.description,
    this.urlDePagamento,
    this.urlComprovante,
    this.qrCodePix,
    this.externalReference,
    required this.idempotencyKey,
    this.externalId,
    this.metadata = const {},
    this.requisicaoGateway = const {},
    this.respostaGateway = const {},
    this.pagoEm,
    this.canceladoEm,
    this.motivoCancelamento,
    required this.customer,
    this.urlPagamentoAvulsoSiteEmpresa,
  });

  factory PagamentoAvulsoDto.fromJson(Map<String, dynamic> json) {
    final customerJson =
        (json['customer'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return PagamentoAvulsoDto(
      criadoEm: _parseDateTime(json['criadoEm']),
      atualizadoEm: _parseDateTime(json['atualizadoEm']),
      id: (json['id'] as num?)?.toInt(),
      empresaId: (json['empresaId'] as num?)?.toInt(),
      usuarioId: (json['usuarioId'] as num?)?.toInt(),
      provider: (json['provider'] as String?) ?? 'noop',
      status: json['status'] as String?,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      description: (json['description'] as String?) ?? '',
      urlDePagamento: (json['urlDePagamento'] as String?) ??
          (json['payment_url'] as String?) ??
          (json['url'] as String?),
      urlComprovante: (json['urlComprovante'] as String?) ??
          (json['receipt_url'] as String?),
      qrCodePix: (json['qrCodePix'] as String?) ??
          (json['qr_code_pix'] as String?) ??
          (json['pixCopiaECola'] as String?),
      externalReference: json['externalReference'] as String?,
      idempotencyKey: (json['idempotencyKey'] as String?) ?? '',
      externalId: json['externalId'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
      requisicaoGateway:
          (json['requisicaoGateway'] as Map<String, dynamic>?) ?? const {},
      respostaGateway:
          (json['respostaGateway'] as Map<String, dynamic>?) ?? const {},
      pagoEm: _parseDateTime(json['pagoEm']),
      canceladoEm: _parseDateTime(json['canceladoEm']),
      motivoCancelamento: json['motivoCancelamento'] as String?,
      customer: PagamentoAvulsoCustomerDto.fromJson(
        customerJson,
      ),
      urlPagamentoAvulsoSiteEmpresa:
          (json['urlPagamentoAvulsoSiteEmpresa'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'criadoEm': criadoEm?.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
      'id': id,
      'empresaId': empresaId,
      'usuarioId': usuarioId,
      'provider': provider,
      'status': status,
      'amount': amount,
      'description': description,
      'urlDePagamento': urlDePagamento,
      'urlComprovante': urlComprovante,
      'qrCodePix': qrCodePix,
      'externalReference': externalReference,
      'idempotencyKey': idempotencyKey,
      'externalId': externalId,
      'metadata': metadata,
      'requisicaoGateway': requisicaoGateway,
      'respostaGateway': respostaGateway,
      'pagoEm': pagoEm?.toIso8601String(),
      'canceladoEm': canceladoEm?.toIso8601String(),
      'motivoCancelamento': motivoCancelamento,
      'customer': customer.toJson(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'provider': provider,
      'amount': amount,
      'description': description,
      'idempotencyKey': idempotencyKey,
      'customer': customer.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        criadoEm,
        atualizadoEm,
        id,
        empresaId,
        usuarioId,
        provider,
        status,
        amount,
        description,
        urlDePagamento,
        urlComprovante,
        qrCodePix,
        externalReference,
        idempotencyKey,
        externalId,
        metadata,
        requisicaoGateway,
        respostaGateway,
        pagoEm,
        canceladoEm,
        motivoCancelamento,
        customer,
      ];

  @override
  bool? get stringify => true;

  @override
  final String? urlPagamentoAvulsoSiteEmpresa;
}

class PagamentoAvulsoCustomerDto implements PagamentoAvulsoCustomer {
  @override
  final String nome;

  @override
  final String documento;

  @override
  final String email;

  @override
  final String telefone;

  const PagamentoAvulsoCustomerDto({
    required this.nome,
    required this.documento,
    required this.email,
    required this.telefone,
  });

  factory PagamentoAvulsoCustomerDto.fromJson(Map<String, dynamic> json) {
    return PagamentoAvulsoCustomerDto(
      nome: (json['nome'] as String?) ?? '',
      documento: (json['documento'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      telefone: (json['telefone'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'documento': documento,
      'email': email,
      'telefone': telefone,
    };
  }

  @override
  List<Object?> get props => [nome, documento, email, telefone];

  @override
  bool? get stringify => true;
}

extension PagamentoAvulsoToDto on PagamentoAvulso {
  PagamentoAvulsoDto toDto() {
    return PagamentoAvulsoDto(
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm,
      id: id,
      empresaId: empresaId,
      usuarioId: usuarioId,
      provider: provider,
      status: status,
      amount: amount,
      description: description,
      urlDePagamento: urlDePagamento,
      urlComprovante: urlComprovante,
      qrCodePix: qrCodePix,
      externalReference: externalReference,
      idempotencyKey: idempotencyKey,
      externalId: externalId,
      metadata: metadata,
      requisicaoGateway: requisicaoGateway,
      respostaGateway: respostaGateway,
      pagoEm: pagoEm,
      canceladoEm: canceladoEm,
      motivoCancelamento: motivoCancelamento,
      customer: PagamentoAvulsoCustomerDto(
        nome: customer.nome,
        documento: customer.documento,
        email: customer.email,
        telefone: customer.telefone,
      ),
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
