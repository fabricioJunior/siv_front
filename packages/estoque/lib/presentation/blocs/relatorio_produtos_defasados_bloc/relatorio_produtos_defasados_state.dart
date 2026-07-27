part of 'relatorio_produtos_defasados_bloc.dart';

enum RelatorioProdutosDefasadosStep { inicial, carregando, sucesso, falha }

class RelatorioProdutosDefasadosState {
  final RelatorioProdutosDefasadosStep step;
  final RelatorioProdutosDefasados? dados;
  final String? erro;
  final int dias;
  final String tipoMovimentacao;
  final String visualizacao;
  final String? dataReferencia;
  final String? busca;
  final int page;
  final int totalPages;

  const RelatorioProdutosDefasadosState({
    required this.step,
    this.dados,
    this.erro,
    required this.dias,
    required this.tipoMovimentacao,
    required this.visualizacao,
    this.dataReferencia,
    this.busca,
    required this.page,
    required this.totalPages,
  });

  const RelatorioProdutosDefasadosState.initial()
      : step = RelatorioProdutosDefasadosStep.inicial,
        dados = null,
        erro = null,
        dias = 90,
        tipoMovimentacao = 'ambas',
        visualizacao = 'produto',
        dataReferencia = null,
        busca = null,
        page = 1,
        totalPages = 1;

  RelatorioProdutosDefasadosState copyWith({
    RelatorioProdutosDefasadosStep? step,
    RelatorioProdutosDefasados? dados,
    String? erro,
    int? dias,
    String? tipoMovimentacao,
    String? visualizacao,
    String? dataReferencia,
    String? busca,
    int? page,
    int? totalPages,
  }) =>
      RelatorioProdutosDefasadosState(
        step: step ?? this.step,
        dados: dados ?? this.dados,
        erro: erro,
        dias: dias ?? this.dias,
        tipoMovimentacao: tipoMovimentacao ?? this.tipoMovimentacao,
        visualizacao: visualizacao ?? this.visualizacao,
        dataReferencia: dataReferencia ?? this.dataReferencia,
        busca: busca ?? this.busca,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
      );
}
