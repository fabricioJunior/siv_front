part of 'historico_estoque_bloc.dart';

enum HistoricoEstoqueStep { inicial, carregando, carregandoMais, carregado, falha }

class HistoricoEstoqueState extends Equatable {
  final HistoricoEstoqueStep step;
  final List<HistoricoEstoque> itens;
  final FiltroHistoricoEstoque filtro;
  final int totalPages;
  final int totalItems;
  final String? erro;

  const HistoricoEstoqueState({
    this.step = HistoricoEstoqueStep.inicial,
    this.itens = const [],
    this.filtro = const FiltroHistoricoEstoque(),
    this.totalPages = 0,
    this.totalItems = 0,
    this.erro,
  });

  bool get temMaisPaginas => filtro.page < totalPages;

  HistoricoEstoqueState copyWith({
    HistoricoEstoqueStep? step,
    List<HistoricoEstoque>? itens,
    FiltroHistoricoEstoque? filtro,
    int? totalPages,
    int? totalItems,
    Object? erro = _sentinelaErro,
  }) {
    return HistoricoEstoqueState(
      step: step ?? this.step,
      itens: itens ?? this.itens,
      filtro: filtro ?? this.filtro,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      erro: identical(erro, _sentinelaErro) ? this.erro : erro as String?,
    );
  }

  @override
  List<Object?> get props => [
    step,
    itens,
    filtro,
    totalPages,
    totalItems,
    erro,
  ];
}

const Object _sentinelaErro = Object();
