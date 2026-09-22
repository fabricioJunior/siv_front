part of 'origens_pagamento_despesa_bloc.dart';

abstract class OrigensPagamentoDespesaEvent {}

class OrigensPagamentoDespesaIniciou extends OrigensPagamentoDespesaEvent {
  final int empresaId;
  final String? busca;

  OrigensPagamentoDespesaIniciou({required this.empresaId, this.busca});
}
