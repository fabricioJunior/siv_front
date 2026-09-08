part of 'pedidos_bloc.dart';

abstract class PedidosEvent {}

class PedidosIniciou extends PedidosEvent {}

class PedidosBuscaAlterada extends PedidosEvent {
  final String busca;

  PedidosBuscaAlterada(this.busca);
}

// Um unico Set cobre situacao (em_andamento/conferido/faturado/encerrado/cancelado) e
// situacaoPagamento (pago) -- filtro multi-selecao, qualquer chip marcado entra no resultado
// (OR entre os selecionados). Set vazio = sem filtro (mostra tudo), mesmo efeito do "Todos".
class PedidosFiltroSituacaoAlterado extends PedidosEvent {
  final Set<String> situacoes;

  PedidosFiltroSituacaoAlterado(this.situacoes);
}

class PedidosPedidoCancelou extends PedidosEvent {
  final int pedidoId;
  final String motivoCancelamento;

  PedidosPedidoCancelou(this.pedidoId, {required this.motivoCancelamento});
}

// Disparado pela tela ao chegar perto do fim da lista (scroll infinito) -- busca a proxima
// pagina e concatena em `pedidos`, sem recarregar o que ja foi carregado.
class PedidosCarregarMais extends PedidosEvent {}

// Filtro local (mesmo criterio de busca/situacao) sobre `criadoEm` do pedido. Ambos nulos = sem
// filtro de periodo.
class PedidosFiltroPeriodoAlterado extends PedidosEvent {
  final DateTime? dataInicial;
  final DateTime? dataFinal;

  PedidosFiltroPeriodoAlterado({this.dataInicial, this.dataFinal});
}

// Selecao de linha na tabela -- carrega os itens do pedido pra alimentar o painel direito.
// id null limpa a selecao (fecha o painel).
class PedidosPedidoSelecionou extends PedidosEvent {
  final int? id;

  PedidosPedidoSelecionou(this.id);
}
