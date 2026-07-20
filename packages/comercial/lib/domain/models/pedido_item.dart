import 'package:core/equals.dart';

abstract class PedidoItem implements Equatable {
  int? get pedidoId;
  int? get produtoId;
  int? get sequencia;
  double? get solicitado;
  double? get atendido;
  double? get valorUnitario;
  double? get valorUnitDesconto;
  int? get referenciaId;
  String? get referenciaNome;
  String? get corNome;
  String? get tamanhoNome;

  factory PedidoItem.create({
    int? pedidoId,
    int? produtoId,
    int? sequencia,
    double? solicitado,
    double? atendido,
    double? valorUnitario,
    double? valorUnitDesconto,
    int? referenciaId,
    String? referenciaNome,
    String? corNome,
    String? tamanhoNome,
  }) = _PedidoItemImpl;

  @override
  List<Object?> get props => [
        pedidoId,
        produtoId,
        sequencia,
        solicitado,
        atendido,
        valorUnitario,
        valorUnitDesconto,
        referenciaId,
        referenciaNome,
        corNome,
        tamanhoNome,
      ];

  @override
  bool? get stringify => true;
}

class _PedidoItemImpl implements PedidoItem {
  @override
  final int? pedidoId;
  @override
  final int? produtoId;
  @override
  final int? sequencia;
  @override
  final double? solicitado;
  @override
  final double? atendido;
  @override
  final double? valorUnitario;
  @override
  final double? valorUnitDesconto;
  @override
  final int? referenciaId;
  @override
  final String? referenciaNome;
  @override
  final String? corNome;
  @override
  final String? tamanhoNome;

  const _PedidoItemImpl({
    this.pedidoId,
    this.produtoId,
    this.sequencia,
    this.solicitado,
    this.atendido,
    this.valorUnitario,
    this.valorUnitDesconto,
    this.referenciaId,
    this.referenciaNome,
    this.corNome,
    this.tamanhoNome,
  });

  @override
  List<Object?> get props => [
        pedidoId,
        produtoId,
        sequencia,
        solicitado,
        atendido,
        valorUnitario,
        valorUnitDesconto,
        referenciaId,
        referenciaNome,
        corNome,
        tamanhoNome,
      ];

  @override
  bool? get stringify => true;
}
