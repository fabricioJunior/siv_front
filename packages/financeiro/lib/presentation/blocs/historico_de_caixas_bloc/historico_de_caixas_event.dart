part of 'historico_de_caixas_bloc.dart';

sealed class HistoricoDeCaixasEvent {
  const HistoricoDeCaixasEvent();
}

class HistoricoDeCaixasIniciou extends HistoricoDeCaixasEvent {
  final FiltroHistoricoDeCaixas filtro;

  const HistoricoDeCaixasIniciou({required this.filtro});
}

class HistoricoDeCaixasCarregarMaisSolicitado extends HistoricoDeCaixasEvent {
  const HistoricoDeCaixasCarregarMaisSolicitado();
}
