import 'package:core/equals.dart';

enum FiltroDisponibilidadeEstoque { todos, comEstoque, semEstoque }

enum CampoOrdenacaoEstoque {
  nome,
  saldo,
  referenciaIdExterno,
  atualizadoEm,
  corNome,
  tamanhoNome,
}

enum DirecaoOrdenacaoEstoque { asc, desc }

/// Um critério de ordenação combinada: a posição na lista de
/// [FiltroProdutoDoEstoque.ordenacoes] define a prioridade (o primeiro
/// desempata usando o segundo, e assim por diante) — ex: ordenar por
/// referência e, dentro da mesma referência, por saldo.
class OrdenacaoEstoqueItem extends Equatable {
  final CampoOrdenacaoEstoque campo;
  final DirecaoOrdenacaoEstoque direcao;

  const OrdenacaoEstoqueItem({
    required this.campo,
    this.direcao = DirecaoOrdenacaoEstoque.asc,
  });

  OrdenacaoEstoqueItem copyWith({
    CampoOrdenacaoEstoque? campo,
    DirecaoOrdenacaoEstoque? direcao,
  }) {
    return OrdenacaoEstoqueItem(
      campo: campo ?? this.campo,
      direcao: direcao ?? this.direcao,
    );
  }

  @override
  List<Object?> get props => [campo, direcao];
}

class FiltroProdutoDoEstoque extends Equatable {
  final List<int> empresaIds;
  final List<int> referenciaIds;
  final List<String> referenciaIdExternos;
  final List<int> produtoIds;
  final List<String> produtoIdExternos;
  final List<int> corIds;
  final List<int> tamanhoIds;
  final int page;
  final int limit;
  final FiltroDisponibilidadeEstoque disponibilidadeEstoque;
  final DateTime? atualizadoEmInicio;
  final DateTime? atualizadoEmFim;
  final DateTime? ultimaAtualizacaoInicio;
  final DateTime? ultimaAtualizacaoFim;
  final List<OrdenacaoEstoqueItem> ordenacoes;

  const FiltroProdutoDoEstoque({
    this.empresaIds = const [],
    this.referenciaIds = const [],
    this.referenciaIdExternos = const [],
    this.produtoIds = const [],
    this.produtoIdExternos = const [],
    this.corIds = const [],
    this.tamanhoIds = const [],
    this.page = 1,
    this.limit = 20,
    this.disponibilidadeEstoque = FiltroDisponibilidadeEstoque.todos,
    this.atualizadoEmInicio,
    this.atualizadoEmFim,
    this.ultimaAtualizacaoFim,
    this.ultimaAtualizacaoInicio,
    this.ordenacoes = const [],
  });

  FiltroProdutoDoEstoque copyWith({
    List<int>? empresaIds,
    List<int>? referenciaIds,
    List<String>? referenciaIdExternos,
    List<int>? produtoIds,
    List<String>? produtoIdExternos,
    List<int>? corIds,
    List<int>? tamanhoIds,
    int? page,
    int? limit,
    FiltroDisponibilidadeEstoque? disponibilidadeEstoque,
    DateTime? atualizadoEmInicio,
    DateTime? atualizadoEmFim,
    DateTime? ultimaAtualizacaoInicio,
    DateTime? ultimaAtualizacaoFim,
    List<OrdenacaoEstoqueItem>? ordenacoes,
  }) {
    return FiltroProdutoDoEstoque(
      empresaIds: empresaIds ?? this.empresaIds,
      referenciaIds: referenciaIds ?? this.referenciaIds,
      referenciaIdExternos: referenciaIdExternos ?? this.referenciaIdExternos,
      produtoIds: produtoIds ?? this.produtoIds,
      produtoIdExternos: produtoIdExternos ?? this.produtoIdExternos,
      corIds: corIds ?? this.corIds,
      tamanhoIds: tamanhoIds ?? this.tamanhoIds,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      disponibilidadeEstoque:
          disponibilidadeEstoque ?? this.disponibilidadeEstoque,
        atualizadoEmInicio: atualizadoEmInicio ?? this.atualizadoEmInicio,
        atualizadoEmFim: atualizadoEmFim ?? this.atualizadoEmFim,
      ultimaAtualizacaoInicio:
          ultimaAtualizacaoInicio ?? this.ultimaAtualizacaoInicio,
      ultimaAtualizacaoFim: ultimaAtualizacaoFim ?? this.ultimaAtualizacaoFim,
      ordenacoes: ordenacoes ?? this.ordenacoes,
    );
  }

  @override
  List<Object?> get props => [
    empresaIds,
    referenciaIds,
    referenciaIdExternos,
    produtoIds,
    produtoIdExternos,
    corIds,
    tamanhoIds,
    page,
    limit,
    disponibilidadeEstoque,
    atualizadoEmInicio,
    atualizadoEmFim,
    ultimaAtualizacaoInicio,
    ultimaAtualizacaoFim,
    ordenacoes,
  ];
}
