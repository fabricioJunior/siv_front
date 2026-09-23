part of 'origens_pagamento_despesa_bloc.dart';

abstract class OrigensPagamentoDespesaState extends Equatable {
  final List<OrigemPagamentoDespesa> origens;

  /// `null` até selecionar uma linha ou clicar "Nova origem"; a partir daí
  /// controla o formulário de edição em linha (id não-nulo em `formId` =
  /// edição de uma origem existente).
  final bool editando;
  final int? formId;
  final String formNome;
  final TipoOrigemPagamentoDespesa formTipo;
  final int? formDiaVencimento;
  final int? formPrazoFechamentoDias;
  final bool salvando;
  final String? erro;

  const OrigensPagamentoDespesaState({
    this.origens = const [],
    this.editando = false,
    this.formId,
    this.formNome = '',
    this.formTipo = TipoOrigemPagamentoDespesa.dinheiro,
    this.formDiaVencimento,
    this.formPrazoFechamentoDias,
    this.salvando = false,
    this.erro,
  });

  @override
  List<Object?> get props => [
        origens,
        editando,
        formId,
        formNome,
        formTipo,
        formDiaVencimento,
        formPrazoFechamentoDias,
        salvando,
        erro,
      ];
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
  const OrigensPagamentoDespesaCarregarSucesso({
    required super.origens,
    super.editando,
    super.formId,
    super.formNome,
    super.formTipo,
    super.formDiaVencimento,
    super.formPrazoFechamentoDias,
    super.salvando,
    super.erro,
  });

  OrigensPagamentoDespesaCarregarSucesso copyWith({
    List<OrigemPagamentoDespesa>? origens,
    bool? editando,
    int? formId,
    bool limparFormId = false,
    String? formNome,
    TipoOrigemPagamentoDespesa? formTipo,
    int? formDiaVencimento,
    int? formPrazoFechamentoDias,
    bool? salvando,
    String? erro,
  }) {
    return OrigensPagamentoDespesaCarregarSucesso(
      origens: origens ?? this.origens,
      editando: editando ?? this.editando,
      formId: limparFormId ? null : (formId ?? this.formId),
      formNome: formNome ?? this.formNome,
      formTipo: formTipo ?? this.formTipo,
      formDiaVencimento: formDiaVencimento ?? this.formDiaVencimento,
      formPrazoFechamentoDias: formPrazoFechamentoDias ?? this.formPrazoFechamentoDias,
      salvando: salvando ?? this.salvando,
      erro: erro,
    );
  }
}

class OrigensPagamentoDespesaCarregarFalha
    extends OrigensPagamentoDespesaState {
  const OrigensPagamentoDespesaCarregarFalha({required super.origens});
}
