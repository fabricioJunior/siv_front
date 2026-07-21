part of 'forma_de_pagamento_bloc.dart';

class FormaDePagamentoState extends Equatable {
  final int? id;
  final String? descricao;
  final int? inicio;
  final int? parcelas;
  final String? tipo;
  final bool? inativa;
  final TipoOperacaoFormaPagamento tipoOperacao;
  final String? provider;
  final FormaDePagamento? formaDePagamento;
  final String? erro;
  final FormaDePagamentoStep step;

  const FormaDePagamentoState({
    this.id,
    this.descricao,
    this.inicio,
    this.parcelas,
    this.tipo,
    this.inativa,
    this.tipoOperacao = TipoOperacaoFormaPagamento.manual,
    this.provider,
    this.formaDePagamento,
    this.erro,
    required this.step,
  });

  FormaDePagamentoState.fromModel(
    FormaDePagamento forma, {
    FormaDePagamentoStep? step,
  })  : id = forma.id,
        descricao = forma.descricao,
        inicio = forma.inicio,
        parcelas = forma.parcelas,
        tipo = forma.tipo,
        inativa = forma.inativa,
        tipoOperacao = forma.tipoOperacao,
        provider = forma.provider,
        formaDePagamento = forma,
        erro = null,
        step = step ?? FormaDePagamentoStep.editando;

  FormaDePagamentoState copyWith({
    int? id,
    String? descricao,
    int? inicio,
    int? parcelas,
    String? tipo,
    bool? inativa,
    TipoOperacaoFormaPagamento? tipoOperacao,
    String? provider,
    bool limparProvider = false,
    FormaDePagamento? formaDePagamento,
    String? erro,
    FormaDePagamentoStep? step,
  }) {
    return FormaDePagamentoState(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      inicio: inicio ?? this.inicio,
      parcelas: parcelas ?? this.parcelas,
      tipo: tipo ?? this.tipo,
      inativa: inativa ?? this.inativa,
      tipoOperacao: tipoOperacao ?? this.tipoOperacao,
      provider: limparProvider ? null : (provider ?? this.provider),
      formaDePagamento: formaDePagamento ?? this.formaDePagamento,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        id,
        descricao,
        inicio,
        parcelas,
        tipo,
        inativa,
        tipoOperacao,
        provider,
        formaDePagamento,
        erro,
        step,
      ];
}

enum FormaDePagamentoStep {
  inicial,
  carregando,
  editando,
  salvando,
  criado,
  salvo,
  validacaoInvalida,
  falha,
}
