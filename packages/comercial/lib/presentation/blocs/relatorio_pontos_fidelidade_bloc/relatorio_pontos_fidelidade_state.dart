part of 'relatorio_pontos_fidelidade_bloc.dart';

enum RelatorioPontosFidelidadeStep { inicial, carregando, sucesso, falha }

class RelatorioPontosFidelidadeState {
  final RelatorioPontosFidelidadeStep step;
  final RelatorioPontosFidelidade? dados;
  final String? erro;
  final String? situacaoCadastro;
  final int page;
  final int totalPages;

  const RelatorioPontosFidelidadeState({
    required this.step,
    this.dados,
    this.erro,
    this.situacaoCadastro,
    required this.page,
    required this.totalPages,
  });

  const RelatorioPontosFidelidadeState.initial()
      : step = RelatorioPontosFidelidadeStep.inicial,
        dados = null,
        erro = null,
        situacaoCadastro = null,
        page = 1,
        totalPages = 1;

  RelatorioPontosFidelidadeState copyWith({
    RelatorioPontosFidelidadeStep? step,
    RelatorioPontosFidelidade? dados,
    String? erro,
    String? situacaoCadastro,
    bool limparSituacaoCadastro = false,
    int? page,
    int? totalPages,
  }) =>
      RelatorioPontosFidelidadeState(
        step: step ?? this.step,
        dados: dados ?? this.dados,
        erro: erro,
        situacaoCadastro: limparSituacaoCadastro
            ? null
            : situacaoCadastro ?? this.situacaoCadastro,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
      );
}
