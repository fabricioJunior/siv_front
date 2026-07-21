part of 'forma_de_pagamento_bloc.dart';

abstract class FormaDePagamentoEvent {}

class FormaDePagamentoIniciou extends FormaDePagamentoEvent {
  final int? idFormaDePagamento;

  FormaDePagamentoIniciou({this.idFormaDePagamento});
}

class FormaDePagamentoCampoAlterado extends FormaDePagamentoEvent {
  final String? descricao;
  final int? inicio;
  final int? parcelas;
  final String? tipo;
  final bool? inativa;
  final TipoOperacaoFormaPagamento? tipoOperacao;
  final String? provider;
  final bool limparProvider;

  FormaDePagamentoCampoAlterado({
    this.descricao,
    this.inicio,
    this.parcelas,
    this.tipo,
    this.inativa,
    this.tipoOperacao,
    this.provider,
    this.limparProvider = false,
  });
}

class FormaDePagamentoSalvou extends FormaDePagamentoEvent {}
