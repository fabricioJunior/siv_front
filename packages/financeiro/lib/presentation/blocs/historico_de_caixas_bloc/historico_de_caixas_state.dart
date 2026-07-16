part of 'historico_de_caixas_bloc.dart';

enum HistoricoDeCaixasStep {
  inicial,
  carregando,
  carregandoMais,
  carregado,
  falha,
}

class HistoricoDeCaixasState extends Equatable {
  final HistoricoDeCaixasStep step;
  final List<CaixaDoHistorico> itens;
  final FiltroHistoricoDeCaixas filtro;
  final int totalPages;
  final int totalItems;
  final String? erro;

  const HistoricoDeCaixasState({
    this.step = HistoricoDeCaixasStep.inicial,
    this.itens = const [],
    this.filtro = const FiltroHistoricoDeCaixas(),
    this.totalPages = 0,
    this.totalItems = 0,
    this.erro,
  });

  bool get temMaisPaginas => filtro.page < totalPages;

  HistoricoDeCaixasState copyWith({
    HistoricoDeCaixasStep? step,
    List<CaixaDoHistorico>? itens,
    FiltroHistoricoDeCaixas? filtro,
    int? totalPages,
    int? totalItems,
    Object? erro = _sentinelaErro,
  }) {
    return HistoricoDeCaixasState(
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
