part of 'origens_pagamento_despesa_bloc.dart';

abstract class OrigensPagamentoDespesaEvent {}

class OrigensPagamentoDespesaIniciou extends OrigensPagamentoDespesaEvent {
  final int empresaId;
  final String? busca;

  OrigensPagamentoDespesaIniciou({required this.empresaId, this.busca});
}

/// Seleciona uma origem pra editar (id != null) ou limpa o formulário pra
/// "Nova origem" (id == null).
class OrigensPagamentoDespesaSelecionou extends OrigensPagamentoDespesaEvent {
  final int? id;

  OrigensPagamentoDespesaSelecionou({this.id});
}

class OrigensPagamentoDespesaCampoAlterado extends OrigensPagamentoDespesaEvent {
  final String? nome;
  final TipoOrigemPagamentoDespesa? tipo;
  final int? diaVencimento;
  final int? prazoFechamentoDias;

  OrigensPagamentoDespesaCampoAlterado({
    this.nome,
    this.tipo,
    this.diaVencimento,
    this.prazoFechamentoDias,
  });
}

class OrigensPagamentoDespesaSalvou extends OrigensPagamentoDespesaEvent {
  final int empresaId;

  OrigensPagamentoDespesaSalvou({required this.empresaId});
}
