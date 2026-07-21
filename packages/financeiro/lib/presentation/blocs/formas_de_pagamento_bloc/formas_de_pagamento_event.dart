part of 'formas_de_pagamento_bloc.dart';

abstract class FormasDePagamentoEvent {}

class FormasDePagamentoIniciou extends FormasDePagamentoEvent {
  final String? busca;

  FormasDePagamentoIniciou({this.busca});
}

// Filtro por tipoOperacao (manual/online) é aplicado sobre a lista já
// carregada -- não dispara nova busca na API.
class FormasDePagamentoFiltroTipoOperacaoAlterado
    extends FormasDePagamentoEvent {
  final TipoOperacaoFormaPagamento? tipoOperacao;

  FormasDePagamentoFiltroTipoOperacaoAlterado(this.tipoOperacao);
}
