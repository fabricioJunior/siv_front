part of 'relatorio_fiscal_bloc.dart';

class RelatorioFiscalState extends Equatable {
  final List<DocumentoFiscal> items;
  final int total;
  final int page;
  final ResumoFiscal? resumo;
  final String? erro;
  final RelatorioFiscalStep step;

  const RelatorioFiscalState({
    required this.items,
    required this.total,
    required this.page,
    this.resumo,
    this.erro,
    required this.step,
  });

  const RelatorioFiscalState.initial()
      : items = const [],
        total = 0,
        page = 1,
        resumo = null,
        erro = null,
        step = RelatorioFiscalStep.inicial;

  RelatorioFiscalState copyWith({
    List<DocumentoFiscal>? items,
    int? total,
    int? page,
    ResumoFiscal? resumo,
    String? erro,
    RelatorioFiscalStep? step,
  }) {
    return RelatorioFiscalState(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      resumo: resumo ?? this.resumo,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [items, total, page, resumo, erro, step];
}

enum RelatorioFiscalStep { inicial, carregando, sucesso, falha }
