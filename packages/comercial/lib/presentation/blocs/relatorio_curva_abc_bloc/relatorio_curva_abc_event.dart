part of 'relatorio_curva_abc_bloc.dart';

abstract class RelatorioCurvaAbcEvent {}

class RelatorioCurvaAbcCarregar extends RelatorioCurvaAbcEvent {
  final String dataInicial;
  final String dataFinal;
  final int page;

  RelatorioCurvaAbcCarregar({
    required this.dataInicial,
    required this.dataFinal,
    this.page = 1,
  });
}
