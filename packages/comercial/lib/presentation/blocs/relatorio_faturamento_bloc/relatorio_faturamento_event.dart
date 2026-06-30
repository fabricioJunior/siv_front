part of 'relatorio_faturamento_bloc.dart';

abstract class RelatorioFaturamentoEvent {}

class RelatorioFaturamentoCarregar extends RelatorioFaturamentoEvent {
  final String dataInicial;
  final String dataFinal;
  RelatorioFaturamentoCarregar({
    required this.dataInicial,
    required this.dataFinal,
  });
}
