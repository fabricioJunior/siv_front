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
  final String? valorTaxaEntrega;

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
    this.valorTaxaEntrega,
  });
}

class PedidoModalidadeEntregaAlterada extends PedidoEvent {
  final String modalidadeEntrega;

  PedidoModalidadeEntregaAlterada(this.modalidadeEntrega);
}

class PedidoEnderecoEntregaAlterado extends PedidoEvent {
  final int? enderecoEntregaId;
  final String? enderecoEntregaResumo;

  PedidoEnderecoEntregaAlterado(
    this.enderecoEntregaId, {
    this.enderecoEntregaResumo,
  });
}

class PedidoSalvou extends PedidoEvent {}

class PedidoConferiu extends PedidoEvent {}

class PedidoFaturou extends PedidoEvent {}

class PedidoCancelou extends PedidoEvent {
  final String motivoCancelamento;

  PedidoCancelou(this.motivoCancelamento);
}

class PedidoPagamentoAdicionou extends PedidoEvent {
  final int formaDePagamentoId;
  final double valorEsperado;
  final double? taxaAplicada;

  PedidoPagamentoAdicionou({
    required this.formaDePagamentoId,
    required this.valorEsperado,
    this.taxaAplicada,
  });
}

class PedidoPagamentoConfirmou extends PedidoEvent {
  final int pagamentoId;
  final double valorConfirmado;

  PedidoPagamentoConfirmou({
    required this.pagamentoId,
    required this.valorConfirmado,
  });
}

class PedidoPagamentoRemoveu extends PedidoEvent {
  final int pagamentoId;

  PedidoPagamentoRemoveu({required this.pagamentoId});
}

class PedidoEntregadorChamou extends PedidoEvent {}

class PedidoEntregaConfirmou extends PedidoEvent {}

class PedidoTaxaEntregaCriou extends PedidoEvent {
  final double valorTaxaEntrega;
  final int enderecoEntregaId;

  PedidoTaxaEntregaCriou({
    required this.valorTaxaEntrega,
    required this.enderecoEntregaId,
  });
}

class PedidoItemAdicionou extends PedidoEvent {
  final int produtoId;
  final double quantidade;

  PedidoItemAdicionou({
    required this.produtoId,
    required this.quantidade,
  });
}

class PedidoItemRemoveu extends PedidoEvent {
  final int produtoId;
  final int sequencia;
  final double quantidade;

  PedidoItemRemoveu({
    required this.produtoId,
    required this.sequencia,
    required this.quantidade,
  });
}

class PedidoItemConferiu extends PedidoEvent {
  final int produtoId;
  final int sequencia;
  final double quantidade;

  PedidoItemConferiu({
    required this.produtoId,
    required this.sequencia,
    required this.quantidade,
  });
}
