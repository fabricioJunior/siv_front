part of 'estoque_saldo_bloc.dart';

sealed class EstoqueSaldoEvent {
  const EstoqueSaldoEvent();
}

class EstoqueSaldoIniciou extends EstoqueSaldoEvent {
  final String termoBusca;
  final List<int> corIds;
  final List<int> tamanhoIds;
  final FiltroDisponibilidadeEstoque disponibilidadeEstoque;
  final DateTime? atualizadoEmInicio;
  final DateTime? atualizadoEmFim;
  final List<OrdenacaoEstoqueItem> ordenacoes;
  final bool visualizarPorReferencia;
  final int limit;

  const EstoqueSaldoIniciou({
    this.termoBusca = '',
    this.corIds = const [],
    this.tamanhoIds = const [],
    this.disponibilidadeEstoque = FiltroDisponibilidadeEstoque.todos,
    this.atualizadoEmInicio,
    this.atualizadoEmFim,
    this.ordenacoes = const [],
    this.visualizarPorReferencia = false,
    this.limit = 20,
  });
}

class EstoqueSaldoCarregarMaisSolicitado extends EstoqueSaldoEvent {
  const EstoqueSaldoCarregarMaisSolicitado();
}
