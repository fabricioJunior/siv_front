part of 'formas_de_pagamento_bloc.dart';

abstract class FormasDePagamentoState extends Equatable {
  final List<FormaDePagamento> formasDePagamento;
  final TipoOperacaoFormaPagamento? tipoOperacaoFiltro;

  const FormasDePagamentoState({
    this.formasDePagamento = const [],
    this.tipoOperacaoFiltro,
  });

  List<FormaDePagamento> get formasDePagamentoFiltradas =>
      tipoOperacaoFiltro == null
          ? formasDePagamento
          : formasDePagamento
              .where((forma) => forma.tipoOperacao == tipoOperacaoFiltro)
              .toList(growable: false);

  @override
  List<Object?> get props => [formasDePagamento, tipoOperacaoFiltro];
}

class FormasDePagamentoInitial extends FormasDePagamentoState {
  const FormasDePagamentoInitial();
}

class FormasDePagamentoCarregarEmProgresso extends FormasDePagamentoState {
  const FormasDePagamentoCarregarEmProgresso({
    required super.formasDePagamento,
    super.tipoOperacaoFiltro,
  });
}

class FormasDePagamentoCarregarSucesso extends FormasDePagamentoState {
  const FormasDePagamentoCarregarSucesso({
    required super.formasDePagamento,
    super.tipoOperacaoFiltro,
  });
}

class FormasDePagamentoCarregarFalha extends FormasDePagamentoState {
  const FormasDePagamentoCarregarFalha({
    required super.formasDePagamento,
    super.tipoOperacaoFiltro,
  });
}
