part of 'forma_de_pagamento_bloc.dart';

class FormaDePagamentoState extends Equatable {
  final int? id;
  final String? descricao;
  final int? inicio;
  final int? parcelas;
  final String? tipo;
  final bool? inativa;
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
