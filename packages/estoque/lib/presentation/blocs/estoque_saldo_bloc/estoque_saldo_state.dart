part of 'estoque_saldo_bloc.dart';

enum EstoqueSaldoStep { inicial, carregando, carregandoMais, carregado, falha }

class EstoqueSaldoState extends Equatable {
  final EstoqueSaldoStep step;
  final List<ProdutoDoEstoque> itens;
  final int page;
  final int limit;
  final int totalPages;
  final int totalItems;
  final String termoBusca;
  final FiltroDisponibilidadeEstoque disponibilidadeEstoque;
  final DateTime? atualizadoEmInicio;
  final DateTime? atualizadoEmFim;
  final List<int> corIdsSelecionadas;
  final List<int> tamanhoIdsSelecionados;
  final bool sincronizando;
  final String? erro;

  const EstoqueSaldoState({
    this.step = EstoqueSaldoStep.inicial,
    this.itens = const [],
    this.page = 1,
    this.limit = 20,
    this.totalPages = 0,
    this.totalItems = 0,
    this.termoBusca = '',
    this.disponibilidadeEstoque = FiltroDisponibilidadeEstoque.todos,
    this.atualizadoEmInicio,
    this.atualizadoEmFim,
    this.corIdsSelecionadas = const [],
    this.tamanhoIdsSelecionados = const [],
    this.sincronizando = false,
    this.erro,
  });

  bool get temMaisPaginas => page < totalPages;

  EstoqueSaldoState copyWith({
    EstoqueSaldoStep? step,
    List<ProdutoDoEstoque>? itens,
    int? page,
    int? limit,
    int? totalPages,
    int? totalItems,
    String? termoBusca,
    FiltroDisponibilidadeEstoque? disponibilidadeEstoque,
    Object? atualizadoEmInicio = _sentinelaErro,
    Object? atualizadoEmFim = _sentinelaErro,
    List<int>? corIdsSelecionadas,
    List<int>? tamanhoIdsSelecionados,
    bool? sincronizando,
    Object? erro = _sentinelaErro,
  }) {
    return EstoqueSaldoState(
      step: step ?? this.step,
      itens: itens ?? this.itens,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      termoBusca: termoBusca ?? this.termoBusca,
      disponibilidadeEstoque:
          disponibilidadeEstoque ?? this.disponibilidadeEstoque,
      atualizadoEmInicio: identical(atualizadoEmInicio, _sentinelaErro)
          ? this.atualizadoEmInicio
          : atualizadoEmInicio as DateTime?,
      atualizadoEmFim: identical(atualizadoEmFim, _sentinelaErro)
          ? this.atualizadoEmFim
          : atualizadoEmFim as DateTime?,
      corIdsSelecionadas: corIdsSelecionadas ?? this.corIdsSelecionadas,
      tamanhoIdsSelecionados:
          tamanhoIdsSelecionados ?? this.tamanhoIdsSelecionados,
      sincronizando: sincronizando ?? this.sincronizando,
      erro: identical(erro, _sentinelaErro) ? this.erro : erro as String?,
    );
  }

  @override
  List<Object?> get props => [
    step,
    itens,
    page,
    limit,
    totalPages,
    totalItems,
    termoBusca,
    disponibilidadeEstoque,
    atualizadoEmInicio,
    atualizadoEmFim,
    corIdsSelecionadas,
    tamanhoIdsSelecionados,
    sincronizando,
    erro,
  ];
}

const Object _sentinelaErro = Object();
