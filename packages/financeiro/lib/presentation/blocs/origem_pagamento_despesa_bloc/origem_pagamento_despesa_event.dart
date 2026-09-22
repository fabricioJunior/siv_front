part of 'origem_pagamento_despesa_bloc.dart';

abstract class OrigemPagamentoDespesaEvent {}

class OrigemPagamentoDespesaIniciou extends OrigemPagamentoDespesaEvent {
  final int empresaId;
  final int? id;

  OrigemPagamentoDespesaIniciou({required this.empresaId, this.id});
}

class OrigemPagamentoDespesaCampoAlterado extends OrigemPagamentoDespesaEvent {
  final String? nome;
  final TipoOrigemPagamentoDespesa? tipo;
  final int? diaVencimento;

  OrigemPagamentoDespesaCampoAlterado({
    this.nome,
    this.tipo,
    this.diaVencimento,
  });
}

class OrigemPagamentoDespesaSalvou extends OrigemPagamentoDespesaEvent {}
