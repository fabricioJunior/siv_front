part of 'pedido_bloc.dart';

abstract class PedidoEvent {}

class PedidoIniciou extends PedidoEvent {
  final int? idPedido;

  PedidoIniciou({this.idPedido});
}

class PedidoCampoAlterado extends PedidoEvent {
  final String? pessoaId;
  final String? funcionarioId;
  final String? tabelaPrecoId;
  final String? parcelas;
  final String? intervalo;
  final String? dataBasePagamento;
  final String? previsaoDeFaturamento;
  final String? previsaoDeEntrega;
  final String? tipo;
  final bool? fiscal;
  final String? observacao;

  PedidoCampoAlterado({
    this.pessoaId,
    this.funcionarioId,
    this.tabelaPrecoId,
    this.parcelas,
    this.intervalo,
    this.dataBasePagamento,
    this.previsaoDeFaturamento,
    this.previsaoDeEntrega,
    this.tipo,
    this.fiscal,
    this.observacao,
  });
}

class PedidoSalvou extends PedidoEvent {}

class PedidoConferiu extends PedidoEvent {}

class PedidoFaturou extends PedidoEvent {}

class PedidoCancelou extends PedidoEvent {
  final String motivoCancelamento;

  PedidoCancelou(this.motivoCancelamento);
}
