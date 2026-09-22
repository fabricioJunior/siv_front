part of 'origem_pagamento_despesa_bloc.dart';

class OrigemPagamentoDespesaState extends Equatable {
  final int? id;
  final int? empresaId;
  final String? nome;
  final TipoOrigemPagamentoDespesa? tipo;
  final int? diaVencimento;
  final int? prazoFechamentoDias;
  final OrigemPagamentoDespesa? origem;
  final String? erro;
  final OrigemPagamentoDespesaStep step;

  const OrigemPagamentoDespesaState({
    this.id,
    this.empresaId,
    this.nome,
    this.tipo,
    this.diaVencimento,
    this.prazoFechamentoDias,
    this.origem,
    this.erro,
    required this.step,
  });

  OrigemPagamentoDespesaState.fromModel(
    OrigemPagamentoDespesa origem, {
    OrigemPagamentoDespesaStep? step,
  })  : id = origem.id,
        empresaId = origem.empresaId,
        nome = origem.nome,
        tipo = origem.tipo,
        diaVencimento = origem.diaVencimento,
        prazoFechamentoDias = origem.prazoFechamentoDias,
        origem = origem,
        erro = null,
        step = step ?? OrigemPagamentoDespesaStep.editando;

  OrigemPagamentoDespesaState copyWith({
    int? id,
    int? empresaId,
    String? nome,
    TipoOrigemPagamentoDespesa? tipo,
    int? diaVencimento,
    int? prazoFechamentoDias,
    OrigemPagamentoDespesa? origem,
    String? erro,
    OrigemPagamentoDespesaStep? step,
  }) {
    return OrigemPagamentoDespesaState(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      prazoFechamentoDias: prazoFechamentoDias ?? this.prazoFechamentoDias,
      origem: origem ?? this.origem,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        id,
        empresaId,
        nome,
        tipo,
        diaVencimento,
        prazoFechamentoDias,
        origem,
        erro,
        step,
      ];
}

enum OrigemPagamentoDespesaStep {
  inicial,
  carregando,
  editando,
  salvando,
  criado,
  salvo,
  validacaoInvalida,
  falha,
}
