part of 'relatorio_posicao_estoque_bloc.dart';

sealed class RelatorioPosicaoEstoqueEvent {
  const RelatorioPosicaoEstoqueEvent();
}

class PosicaoEstoqueIniciou extends RelatorioPosicaoEstoqueEvent {
  const PosicaoEstoqueIniciou();
}

class PosicaoEstoqueFiltrosAlterados extends RelatorioPosicaoEstoqueEvent {
  final List<int> categoriaIds;
  final List<int> corIds;
  final List<int> tamanhoIds;
  final String? situacao;
  const PosicaoEstoqueFiltrosAlterados({
    this.categoriaIds = const [],
    this.corIds = const [],
    this.tamanhoIds = const [],
    this.situacao,
  });
}

class PosicaoEstoqueRupturaAlternada extends RelatorioPosicaoEstoqueEvent {
  const PosicaoEstoqueRupturaAlternada();
}

/// [coluna]: categoria | pecas | valor | percentual.
class PosicaoEstoqueOrdenou extends RelatorioPosicaoEstoqueEvent {
  final String coluna;
  const PosicaoEstoqueOrdenou(this.coluna);
}
