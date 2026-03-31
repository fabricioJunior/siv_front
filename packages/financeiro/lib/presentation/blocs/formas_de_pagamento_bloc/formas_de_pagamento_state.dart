part of 'formas_de_pagamento_bloc.dart';

abstract class FormasDePagamentoState extends Equatable {
  final List<FormaDePagamento> formasDePagamento;

  const FormasDePagamentoState({this.formasDePagamento = const []});

  @override
  List<Object?> get props => [formasDePagamento];
}

class FormasDePagamentoInitial extends FormasDePagamentoState {
  const FormasDePagamentoInitial();
}

class FormasDePagamentoCarregarEmProgresso extends FormasDePagamentoState {
  const FormasDePagamentoCarregarEmProgresso({
    required super.formasDePagamento,
  });
}

class FormasDePagamentoCarregarSucesso extends FormasDePagamentoState {
  const FormasDePagamentoCarregarSucesso({
    required super.formasDePagamento,
  });
}

class FormasDePagamentoCarregarFalha extends FormasDePagamentoState {
  const FormasDePagamentoCarregarFalha({required super.formasDePagamento});
}
