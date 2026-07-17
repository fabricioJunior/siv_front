import 'package:core/equals.dart';

enum FiltroDisponibilidadeEstoque { todos, comEstoque, semEstoque }

enum CampoOrdenacaoEstoque { nome, saldo, referenciaIdExterno, atualizadoEm }

enum DirecaoOrdenacaoEstoque { asc, desc }

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
  final CampoOrdenacaoEstoque? ordenarPor;
  final DirecaoOrdenacaoEstoque ordenarDirecao;

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
    this.ordenarPor,
    this.ordenarDirecao = DirecaoOrdenacaoEstoque.asc,
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
    Object? ordenarPor = _sentinela,
    DirecaoOrdenacaoEstoque? ordenarDirecao,
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
      ordenarPor: identical(ordenarPor, _sentinela)
          ? this.ordenarPor
          : ordenarPor as CampoOrdenacaoEstoque?,
      ordenarDirecao: ordenarDirecao ?? this.ordenarDirecao,
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
    ordenarPor,
    ordenarDirecao,
  ];
}

const Object _sentinela = Object();
