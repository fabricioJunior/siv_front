part of 'relatorio_curva_abc_bloc.dart';

abstract class RelatorioCurvaAbcEvent {}

class RelatorioCurvaAbcCarregar extends RelatorioCurvaAbcEvent {
  final String dataInicial;
  final String dataFinal;
  final String? busca;
  final int page;
  final String agruparPor;
  final List<int>? referenciaIds;
  final List<int>? categoriaIds;

  RelatorioCurvaAbcCarregar({
    required this.dataInicial,
    required this.dataFinal,
    this.busca,
    this.page = 1,
    this.agruparPor = 'produto',
    this.referenciaIds,
    this.categoriaIds,
  });
}
