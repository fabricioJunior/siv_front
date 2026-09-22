part of 'origens_pagamento_despesa_bloc.dart';

abstract class OrigensPagamentoDespesaState extends Equatable {
  final List<OrigemPagamentoDespesa> origens;

  const OrigensPagamentoDespesaState({this.origens = const []});

  @override
  List<Object?> get props => [origens];
}

class OrigensPagamentoDespesaInitial extends OrigensPagamentoDespesaState {
  const OrigensPagamentoDespesaInitial();
}

class OrigensPagamentoDespesaCarregarEmProgresso
    extends OrigensPagamentoDespesaState {
  const OrigensPagamentoDespesaCarregarEmProgresso({required super.origens});
}

class OrigensPagamentoDespesaCarregarSucesso
    extends OrigensPagamentoDespesaState {
  const OrigensPagamentoDespesaCarregarSucesso({required super.origens});
}

class OrigensPagamentoDespesaCarregarFalha
    extends OrigensPagamentoDespesaState {
  const OrigensPagamentoDespesaCarregarFalha({required super.origens});
}
