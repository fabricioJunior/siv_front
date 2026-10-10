part of 'listas_personalizadas_bloc.dart';

enum ListasPersonalizadasStep { inicial, carregando, carregandoMais, carregado, falha }

class ListasPersonalizadasState extends Equatable {
  final ListasPersonalizadasStep step;
  final List<ListaPersonalizadaResumo> itens;
  final int page;
  final int totalPages;
  final int totalItens;
  final ListaTipo? tipo;
  final String? erro;

  const ListasPersonalizadasState({
    this.step = ListasPersonalizadasStep.inicial,
    this.itens = const [],
    this.page = 1,
    this.totalPages = 0,
    this.totalItens = 0,
    this.tipo,
    this.erro,
  });

  bool get temMaisPaginas => page < totalPages;

  ListasPersonalizadasState copyWith({
    ListasPersonalizadasStep? step,
    List<ListaPersonalizadaResumo>? itens,
    int? page,
    int? totalPages,
    int? totalItens,
    ListaTipo? tipo,
    bool limparTipo = false,
    String? erro,
  }) {
    return ListasPersonalizadasState(
      step: step ?? this.step,
      itens: itens ?? this.itens,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalItens: totalItens ?? this.totalItens,
      tipo: limparTipo ? null : (tipo ?? this.tipo),
      erro: erro,
    );
  }

  @override
  List<Object?> get props => [step, itens, page, totalPages, totalItens, tipo, erro];
}
