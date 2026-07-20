import 'package:core/equals.dart';

abstract class PedidoPagamento implements Equatable {
  int? get id;
  int? get pedidoId;
  String? get tipo;
  int? get pagamentoAvulsoId;
  String? get formaPagamento;
  double? get valorEsperado;
  double? get valorConfirmado;
  double? get taxaAplicada;
  DateTime? get confirmadoEm;
  int? get confirmadoPorOperadorId;

  factory PedidoPagamento.create({
    int? id,
    int? pedidoId,
    String? tipo,
    int? pagamentoAvulsoId,
    String? formaPagamento,
    double? valorEsperado,
    double? valorConfirmado,
    double? taxaAplicada,
    DateTime? confirmadoEm,
    int? confirmadoPorOperadorId,
  }) = _PedidoPagamentoImpl;

  @override
  List<Object?> get props => [
        id,
        pedidoId,
        tipo,
        pagamentoAvulsoId,
        formaPagamento,
        valorEsperado,
        valorConfirmado,
        taxaAplicada,
        confirmadoEm,
        confirmadoPorOperadorId,
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
  final String? tipo;
  @override
  final int? pagamentoAvulsoId;
  @override
  final String? formaPagamento;
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

  const _PedidoPagamentoImpl({
    this.id,
    this.pedidoId,
    this.tipo,
    this.pagamentoAvulsoId,
    this.formaPagamento,
    this.valorEsperado,
    this.valorConfirmado,
    this.taxaAplicada,
    this.confirmadoEm,
    this.confirmadoPorOperadorId,
  });

  @override
  List<Object?> get props => [
        id,
        pedidoId,
        tipo,
        pagamentoAvulsoId,
        formaPagamento,
        valorEsperado,
        valorConfirmado,
        taxaAplicada,
        confirmadoEm,
        confirmadoPorOperadorId,
      ];

  @override
  bool? get stringify => true;
}
