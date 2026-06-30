part of 'relatorio_clientes_bloc.dart';

enum RelatorioClientesStep { inicial, carregando, sucesso, falha }

class RelatorioClientesState {
  final RelatorioClientesStep step;
  final RelatorioClientesAtivos? dados;
  final String? erro;
  final int dias;
  final String? dataReferencia;
  final int page;
  final int totalPages;

  const RelatorioClientesState({
    required this.step,
    this.dados,
    this.erro,
    required this.dias,
    this.dataReferencia,
    required this.page,
    required this.totalPages,
  });

  const RelatorioClientesState.initial()
      : step = RelatorioClientesStep.inicial,
        dados = null,
        erro = null,
        dias = 30,
        dataReferencia = null,
        page = 1,
        totalPages = 1;

  RelatorioClientesState copyWith({
    RelatorioClientesStep? step,
    RelatorioClientesAtivos? dados,
    String? erro,
    int? dias,
    String? dataReferencia,
    int? page,
    int? totalPages,
  }) =>
      RelatorioClientesState(
        step: step ?? this.step,
        dados: dados ?? this.dados,
        erro: erro,
        dias: dias ?? this.dias,
        dataReferencia: dataReferencia ?? this.dataReferencia,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
      );
}
