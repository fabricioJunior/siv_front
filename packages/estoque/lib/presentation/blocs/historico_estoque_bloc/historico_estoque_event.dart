part of 'historico_estoque_bloc.dart';

sealed class HistoricoEstoqueEvent {
  const HistoricoEstoqueEvent();
}

class HistoricoEstoqueIniciou extends HistoricoEstoqueEvent {
  final FiltroHistoricoEstoque filtro;

  const HistoricoEstoqueIniciou({required this.filtro});
}

class HistoricoEstoqueCarregarMaisSolicitado extends HistoricoEstoqueEvent {
  const HistoricoEstoqueCarregarMaisSolicitado();
}
