part of 'relatorio_curva_abc_bloc.dart';

abstract class RelatorioCurvaAbcEvent {}

class RelatorioCurvaAbcCarregar extends RelatorioCurvaAbcEvent {
  final String dataInicial;
  final String dataFinal;
  final String? busca;
  final int page;
  final String agruparPor;

  RelatorioCurvaAbcCarregar({
    required this.dataInicial,
    required this.dataFinal,
    this.busca,
    this.page = 1,
    this.agruparPor = 'produto',
  });
}
