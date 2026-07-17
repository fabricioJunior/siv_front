part of 'relatorio_curva_abc_bloc.dart';

enum RelatorioCurvaAbcStep { inicial, carregando, sucesso, falha }

class RelatorioCurvaAbcState {
  final RelatorioCurvaAbcStep step;
  final RelatorioCurvaAbc? dados;
  final String? erro;
  final String dataInicial;
  final String dataFinal;
  final String? busca;
  final int page;
  final int totalPages;
  final String agruparPor;

  const RelatorioCurvaAbcState({
    required this.step,
    this.dados,
    this.erro,
    required this.dataInicial,
    required this.dataFinal,
    this.busca,
    required this.page,
    required this.totalPages,
    this.agruparPor = 'produto',
  });

  factory RelatorioCurvaAbcState.initial() {
    final (ini, fim) = _mesAtualAbc();
    return RelatorioCurvaAbcState(
      step: RelatorioCurvaAbcStep.inicial,
      dataInicial: ini,
      dataFinal: fim,
      page: 1,
      totalPages: 1,
    );
  }

  RelatorioCurvaAbcState copyWith({
    RelatorioCurvaAbcStep? step,
    RelatorioCurvaAbc? dados,
    String? erro,
    String? dataInicial,
    String? dataFinal,
    String? busca,
    bool limparBusca = false,
    int? page,
    int? totalPages,
    String? agruparPor,
  }) =>
      RelatorioCurvaAbcState(
        step: step ?? this.step,
        dados: dados ?? this.dados,
        erro: erro,
        dataInicial: dataInicial ?? this.dataInicial,
        dataFinal: dataFinal ?? this.dataFinal,
        busca: limparBusca ? null : (busca ?? this.busca),
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
        agruparPor: agruparPor ?? this.agruparPor,
      );
}

(String, String) _mesAtualAbc() {
  final now = DateTime.now();
  final ultimo = DateTime(now.year, now.month + 1, 0).day;
  final m = now.month.toString().padLeft(2, '0');
  return (
    '${now.year}-$m-01',
    '${now.year}-$m-${ultimo.toString().padLeft(2, '0')}',
  );
}
