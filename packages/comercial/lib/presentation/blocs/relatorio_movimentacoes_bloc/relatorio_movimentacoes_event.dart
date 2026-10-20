part of 'relatorio_movimentacoes_bloc.dart';

abstract class RelatorioMovimentacoesEvent {}

class RelatorioMovimentacoesIniciou extends RelatorioMovimentacoesEvent {}

class RelatorioMovimentacoesPeriodoAlterou extends RelatorioMovimentacoesEvent {
  final DateTime inicio;
  final DateTime fim;
  RelatorioMovimentacoesPeriodoAlterou(this.inicio, this.fim);
}

/// [tipo] nulo = "Todas" (limpa a seleção).
class RelatorioMovimentacoesTipoAlternou extends RelatorioMovimentacoesEvent {
  final String? tipo;
  RelatorioMovimentacoesTipoAlternou(this.tipo);
}

class RelatorioMovimentacoesBuscou extends RelatorioMovimentacoesEvent {
  final String busca;
  RelatorioMovimentacoesBuscou(this.busca);
}

class RelatorioMovimentacoesMaisCarregou extends RelatorioMovimentacoesEvent {}

class RelatorioMovimentacoesRecarregou extends RelatorioMovimentacoesEvent {}
