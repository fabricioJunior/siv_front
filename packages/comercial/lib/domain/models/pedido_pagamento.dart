import 'package:core/equals.dart';

abstract class PedidoPagamentoCobranca implements Equatable {
  String? get qrCodePix;
  String? get chavePixCopiaECola;
  String? get urlDePagamento;

  factory PedidoPagamentoCobranca.create({
    String? qrCodePix,
    String? chavePixCopiaECola,
    String? urlDePagamento,
  }) = _PedidoPagamentoCobrancaImpl;

  @override
  List<Object?> get props => [qrCodePix, chavePixCopiaECola, urlDePagamento];

  @override
  bool? get stringify => true;
}

class _PedidoPagamentoCobrancaImpl implements PedidoPagamentoCobranca {
  @override
  final String? qrCodePix;
  @override
  final String? chavePixCopiaECola;
  @override
  final String? urlDePagamento;

  const _PedidoPagamentoCobrancaImpl({
    this.qrCodePix,
    this.chavePixCopiaECola,
    this.urlDePagamento,
  });

  @override
  List<Object?> get props => [qrCodePix, chavePixCopiaECola, urlDePagamento];

  @override
  bool? get stringify => true;
}

abstract class PedidoPagamento implements Equatable {
  int? get id;
  int? get pedidoId;
  int? get formaDePagamentoId;
  String? get tipo;
  double? get valorEsperado;
  double? get valorConfirmado;
  double? get taxaAplicada;
  DateTime? get confirmadoEm;
  int? get confirmadoPorOperadorId;
  PedidoPagamentoCobranca? get cobranca;

  factory PedidoPagamento.create({
    int? id,
    int? pedidoId,
    int? formaDePagamentoId,
    String? tipo,
    double? valorEsperado,
    double? valorConfirmado,
    double? taxaAplicada,
    DateTime? confirmadoEm,
    int? confirmadoPorOperadorId,
    PedidoPagamentoCobranca? cobranca,
  }) = _PedidoPagamentoImpl;

  @override
  List<Object?> get props => [
        id,
        pedidoId,
        formaDePagamentoId,
        tipo,
        valorEsperado,
        valorConfirmado,
        taxaAplicada,
        confirmadoEm,
        confirmadoPorOperadorId,
        cobranca,
      ];

  @override
  bool? get stringify => true;
}

class _PedidoPagamentoImpl implements PedidoPagamento {
  @override
  final int? id;
  @override
  final int? pedidoId;
  @override
  final int? formaDePagamentoId;
  @override
  final String? tipo;
  @override
  final double? valorEsperado;
  @override
  final double? valorConfirmado;
  @override
  final double? taxaAplicada;
  @override
  final DateTime? confirmadoEm;
  @override
  final int? confirmadoPorOperadorId;
  @override
  final PedidoPagamentoCobranca? cobranca;

  const _PedidoPagamentoImpl({
    this.id,
    this.pedidoId,
    this.formaDePagamentoId,
    this.tipo,
    this.valorEsperado,
    this.valorConfirmado,
    this.taxaAplicada,
    this.confirmadoEm,
    this.confirmadoPorOperadorId,
    this.cobranca,
  });

  @override
  List<Object?> get props => [
        id,
        pedidoId,
        formaDePagamentoId,
        tipo,
        valorEsperado,
        valorConfirmado,
        taxaAplicada,
        confirmadoEm,
        confirmadoPorOperadorId,
        cobranca,
      ];

  @override
  bool? get stringify => true;
}
