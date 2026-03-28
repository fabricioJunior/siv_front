import 'package:core/equals.dart';

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
  ];
}
