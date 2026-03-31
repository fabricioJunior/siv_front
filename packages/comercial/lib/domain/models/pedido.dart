import 'package:core/equals.dart';

abstract class Pedido implements Equatable {
  int? get id;
  int? get pessoaId;
  int? get funcionarioId;
  int? get tabelaPrecoId;
  DateTime? get dataBasePagamento;
  int? get parcelas;
  int? get intervalo;
  DateTime? get previsaoDeFaturamento;
  DateTime? get previsaoDeEntrega;
  String? get tipo;
  bool? get fiscal;
  String? get observacao;
  String? get situacao;
  String? get motivoCancelamento;
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;

  factory Pedido.create({
    int? id,
    int? pessoaId,
    int? funcionarioId,
    int? tabelaPrecoId,
    DateTime? dataBasePagamento,
    int? parcelas,
    int? intervalo,
    DateTime? previsaoDeFaturamento,
    DateTime? previsaoDeEntrega,
    String? tipo,
    bool? fiscal,
    String? observacao,
    String? situacao,
    String? motivoCancelamento,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) = _PedidoImpl;

  @override
  List<Object?> get props => [
        id,
        pessoaId,
        funcionarioId,
        tabelaPrecoId,
        dataBasePagamento,
        parcelas,
        intervalo,
        previsaoDeFaturamento,
        previsaoDeEntrega,
        tipo,
        fiscal,
        observacao,
        situacao,
        motivoCancelamento,
        criadoEm,
        atualizadoEm,
      ];

  @override
  bool? get stringify => true;
}

class _PedidoImpl implements Pedido {
  @override
  final int? id;
  @override
  final int? pessoaId;
  @override
  final int? funcionarioId;
  @override
  final int? tabelaPrecoId;
  @override
  final DateTime? dataBasePagamento;
  @override
  final int? parcelas;
  @override
  final int? intervalo;
  @override
  final DateTime? previsaoDeFaturamento;
  @override
  final DateTime? previsaoDeEntrega;
  @override
  final String? tipo;
  @override
  final bool? fiscal;
  @override
  final String? observacao;
  @override
  final String? situacao;
  @override
  final String? motivoCancelamento;
  @override
  final DateTime? criadoEm;
  @override
  final DateTime? atualizadoEm;

  const _PedidoImpl({
    this.id,
    this.pessoaId,
    this.funcionarioId,
    this.tabelaPrecoId,
    this.dataBasePagamento,
    this.parcelas,
    this.intervalo,
    this.previsaoDeFaturamento,
    this.previsaoDeEntrega,
    this.tipo,
    this.fiscal,
    this.observacao,
    this.situacao,
    this.motivoCancelamento,
    this.criadoEm,
    this.atualizadoEm,
  });

  @override
  List<Object?> get props => [
        id,
        pessoaId,
        funcionarioId,
        tabelaPrecoId,
        dataBasePagamento,
        parcelas,
        intervalo,
        previsaoDeFaturamento,
        previsaoDeEntrega,
        tipo,
        fiscal,
        observacao,
        situacao,
        motivoCancelamento,
        criadoEm,
        atualizadoEm,
      ];

  @override
  bool? get stringify => true;
}
