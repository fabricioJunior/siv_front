part of 'codigos_de_barras_da_referencia_bloc.dart';

enum CodigosDeBarrasDaReferenciaStep {
  inicial,
  carregando,
  carregandoMais,
  carregado,
  falha,
}

class CodigosDeBarrasDaReferenciaState extends Equatable {
  final CodigosDeBarrasDaReferenciaStep step;
  final List<CodigoBarrasResumo> itens;
  final Map<int, Produto> mapaProdutos;
  final int referenciaId;
  final int page;
  final int totalPages;
  final String? erro;

  const CodigosDeBarrasDaReferenciaState({
    this.step = CodigosDeBarrasDaReferenciaStep.inicial,
    this.itens = const [],
    this.mapaProdutos = const {},
    this.referenciaId = 0,
    this.page = 1,
    this.totalPages = 0,
    this.erro,
  });

  bool get temMaisPaginas => page < totalPages;

  Map<int, List<CodigoBarrasResumo>> get codigosPorProduto {
    final mapa = <int, List<CodigoBarrasResumo>>{};
    for (final item in itens) {
      mapa.putIfAbsent(item.produtoId, () => []).add(item);
    }
    return mapa;
  }

  CodigosDeBarrasDaReferenciaState copyWith({
    CodigosDeBarrasDaReferenciaStep? step,
    List<CodigoBarrasResumo>? itens,
    Map<int, Produto>? mapaProdutos,
    int? referenciaId,
    int? page,
    int? totalPages,
    Object? erro = _sentinelaErro,
  }) {
    return CodigosDeBarrasDaReferenciaState(
      step: step ?? this.step,
      itens: itens ?? this.itens,
      mapaProdutos: mapaProdutos ?? this.mapaProdutos,
      referenciaId: referenciaId ?? this.referenciaId,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      erro: identical(erro, _sentinelaErro) ? this.erro : erro as String?,
    );
  }

  @override
  List<Object?> get props => [
    step,
    itens,
    mapaProdutos,
    referenciaId,
    page,
    totalPages,
    erro,
  ];
}

const Object _sentinelaErro = Object();
