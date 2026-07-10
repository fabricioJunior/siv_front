part of 'pagamentos_avulsos_bloc.dart';

abstract class PagamentosAvulsosEvent {}

class PagamentosAvulsosIniciou extends PagamentosAvulsosEvent {
  final String orderBy;
  final String orderDir;
  final String? descricao;
  final String? provider;

  PagamentosAvulsosIniciou({
    this.orderBy = 'criadoEm',
    this.orderDir = 'DESC',
    this.descricao,
    this.provider,
  });
}

class PagamentosAvulsosProvidersCarregar extends PagamentosAvulsosEvent {}
