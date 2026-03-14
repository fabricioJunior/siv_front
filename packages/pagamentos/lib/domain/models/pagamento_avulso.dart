import 'package:core/equals.dart';

abstract class PagamentoAvulso implements Equatable {
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;
  int? get id;
  int? get empresaId;
  int? get usuarioId;
  String get provider;
  String? get status;
  int get amount;
  String get description;
  String? get urlDePagamento;
  String? get urlComprovante;
  String? get qrCodePix;
  String? get externalReference;
  String get idempotencyKey;
  String? get externalId;
  Map<String, dynamic> get metadata;
  Map<String, dynamic> get requisicaoGateway;
  Map<String, dynamic> get respostaGateway;
  DateTime? get pagoEm;
  DateTime? get canceladoEm;
  String? get motivoCancelamento;
  String? get urlPagamentoAvulsoSiteEmpresa;
  PagamentoAvulsoCustomer get customer;

  factory PagamentoAvulso.create({
    required String provider,
    required int amount,
    required String description,
    String? urlDePagamento,
    String? urlComprovante,
    String? qrCodePix,
    required String idempotencyKey,
    required PagamentoAvulsoCustomer customer,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? id,
    int? empresaId,
    int? usuarioId,
    String? status,
    String? externalReference,
    String? externalId,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? requisicaoGateway,
    Map<String, dynamic>? respostaGateway,
    DateTime? pagoEm,
    DateTime? canceladoEm,
    String? motivoCancelamento,
    String? urlPagamentoAvulsoSiteEmpresa,
  }) = _PagamentoAvulsoImpl;

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
}

class _PagamentoAvulsoImpl implements PagamentoAvulso {
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
  final PagamentoAvulsoCustomer customer;

  @override
  final String? urlPagamentoAvulsoSiteEmpresa;

  _PagamentoAvulsoImpl({
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
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? requisicaoGateway,
    Map<String, dynamic>? respostaGateway,
    this.pagoEm,
    this.canceladoEm,
    this.motivoCancelamento,
    required this.customer,
    this.urlPagamentoAvulsoSiteEmpresa,
  })  : metadata = metadata ?? const {},
        requisicaoGateway = requisicaoGateway ?? const {},
        respostaGateway = respostaGateway ?? const {};

  _PagamentoAvulsoImpl copyWith({
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? id,
    int? empresaId,
    int? usuarioId,
    String? provider,
    String? status,
    int? amount,
    String? description,
    String? urlDePagamento,
    String? urlComprovante,
    String? qrCodePix,
    String? externalReference,
    String? idempotencyKey,
    String? externalId,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? requisicaoGateway,
    Map<String, dynamic>? respostaGateway,
    DateTime? pagoEm,
    DateTime? canceladoEm,
    String? motivoCancelamento,
    PagamentoAvulsoCustomer? customer,
    String? urlPagamentoAvulsoSiteEmpresa,
  }) {
    return _PagamentoAvulsoImpl(
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      usuarioId: usuarioId ?? this.usuarioId,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      urlDePagamento: urlDePagamento ?? this.urlDePagamento,
      urlComprovante: urlComprovante ?? this.urlComprovante,
      qrCodePix: qrCodePix ?? this.qrCodePix,
      externalReference: externalReference ?? this.externalReference,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      externalId: externalId ?? this.externalId,
      metadata: metadata ?? this.metadata,
      requisicaoGateway: requisicaoGateway ?? this.requisicaoGateway,
      respostaGateway: respostaGateway ?? this.respostaGateway,
      pagoEm: pagoEm ?? this.pagoEm,
      canceladoEm: canceladoEm ?? this.canceladoEm,
      motivoCancelamento: motivoCancelamento ?? this.motivoCancelamento,
      customer: customer ?? this.customer,
      urlPagamentoAvulsoSiteEmpresa:
          urlPagamentoAvulsoSiteEmpresa ?? this.urlPagamentoAvulsoSiteEmpresa,
    );
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
}

extension PagamentoAvulsoCopyWith on PagamentoAvulso {
  PagamentoAvulso copyWith({
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? id,
    int? empresaId,
    int? usuarioId,
    String? provider,
    String? status,
    int? amount,
    String? description,
    String? urlDePagamento,
    String? urlComprovante,
    String? qrCodePix,
    String? externalReference,
    String? idempotencyKey,
    String? externalId,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? requisicaoGateway,
    Map<String, dynamic>? respostaGateway,
    DateTime? pagoEm,
    DateTime? canceladoEm,
    String? motivoCancelamento,
    PagamentoAvulsoCustomer? customer,
  }) {
    if (this is _PagamentoAvulsoImpl) {
      return (this as _PagamentoAvulsoImpl).copyWith(
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
        customer: customer,
      );
    }

    return PagamentoAvulso.create(
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      usuarioId: usuarioId ?? this.usuarioId,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      urlDePagamento: urlDePagamento ?? this.urlDePagamento,
      urlComprovante: urlComprovante ?? this.urlComprovante,
      qrCodePix: qrCodePix ?? this.qrCodePix,
      externalReference: externalReference ?? this.externalReference,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      externalId: externalId ?? this.externalId,
      metadata: metadata ?? this.metadata,
      requisicaoGateway: requisicaoGateway ?? this.requisicaoGateway,
      respostaGateway: respostaGateway ?? this.respostaGateway,
      pagoEm: pagoEm ?? this.pagoEm,
      canceladoEm: canceladoEm ?? this.canceladoEm,
      motivoCancelamento: motivoCancelamento ?? this.motivoCancelamento,
      customer: customer ?? this.customer,
    );
  }
}

abstract class PagamentoAvulsoCustomer implements Equatable {
  String get nome;
  String get documento;
  String get email;
  String get telefone;

  factory PagamentoAvulsoCustomer.create({
    required String nome,
    required String documento,
    required String email,
    required String telefone,
  }) = _PagamentoAvulsoCustomerImpl;

  @override
  List<Object?> get props => [nome, documento, email, telefone];

  @override
  bool? get stringify => true;
}

class _PagamentoAvulsoCustomerImpl implements PagamentoAvulsoCustomer {
  @override
  final String nome;

  @override
  final String documento;

  @override
  final String email;

  @override
  final String telefone;

  _PagamentoAvulsoCustomerImpl({
    required this.nome,
    required this.documento,
    required this.email,
    required this.telefone,
  });

  _PagamentoAvulsoCustomerImpl copyWith({
    String? nome,
    String? documento,
    String? email,
    String? telefone,
  }) {
    return _PagamentoAvulsoCustomerImpl(
      nome: nome ?? this.nome,
      documento: documento ?? this.documento,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
    );
  }

  @override
  List<Object?> get props => [nome, documento, email, telefone];

  @override
  bool? get stringify => true;
}

extension PagamentoAvulsoCustomerCopyWith on PagamentoAvulsoCustomer {
  PagamentoAvulsoCustomer copyWith({
    String? nome,
    String? documento,
    String? email,
    String? telefone,
  }) {
    if (this is _PagamentoAvulsoCustomerImpl) {
      return (this as _PagamentoAvulsoCustomerImpl).copyWith(
        nome: nome,
        documento: documento,
        email: email,
        telefone: telefone,
      );
    }

    return PagamentoAvulsoCustomer.create(
      nome: nome ?? this.nome,
      documento: documento ?? this.documento,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
    );
  }
}
