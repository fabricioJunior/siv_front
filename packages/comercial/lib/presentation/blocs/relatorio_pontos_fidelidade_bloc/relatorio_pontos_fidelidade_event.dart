part of 'relatorio_pontos_fidelidade_bloc.dart';

abstract class RelatorioPontosFidelidadeEvent {}

class RelatorioPontosFidelidadeCarregar extends RelatorioPontosFidelidadeEvent {
  final String? situacaoCadastro;
  final int page;

  RelatorioPontosFidelidadeCarregar({
    this.situacaoCadastro,
    this.page = 1,
  });
}
