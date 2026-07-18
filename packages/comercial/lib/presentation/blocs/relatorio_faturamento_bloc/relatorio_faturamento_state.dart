part of 'relatorio_faturamento_bloc.dart';

enum RelatorioFaturamentoStep { inicial, carregando, sucesso, falha }

enum RelatorioFaturamentoComparativoStep {
  ocioso,
  carregando,
  sucesso,
  falha,
}

class RelatorioFaturamentoState {
  final RelatorioFaturamentoStep step;
  final RelatorioFaturamento? dados;
  final String? erro;
  final String dataInicial;
  final String dataFinal;
  final RelatorioFaturamentoComparativoStep comparativoStep;
  final RelatorioFaturamentoComparativo? comparativoDados;
  final String agruparPor;

  const RelatorioFaturamentoState({
    required this.step,
    this.dados,
    this.erro,
    required this.dataInicial,
    required this.dataFinal,
    this.comparativoStep = RelatorioFaturamentoComparativoStep.ocioso,
    this.comparativoDados,
    this.agruparPor = 'mes',
  });

  factory RelatorioFaturamentoState.initial() {
    final (ini, fim) = _mesAtual();
    return RelatorioFaturamentoState(
      step: RelatorioFaturamentoStep.inicial,
      dataInicial: ini,
      dataFinal: fim,
    );
  }

  RelatorioFaturamentoState copyWith({
    RelatorioFaturamentoStep? step,
    RelatorioFaturamento? dados,
    String? erro,
    String? dataInicial,
    String? dataFinal,
    RelatorioFaturamentoComparativoStep? comparativoStep,
    RelatorioFaturamentoComparativo? comparativoDados,
    String? agruparPor,
  }) =>
      RelatorioFaturamentoState(
        step: step ?? this.step,
        dados: dados ?? this.dados,
        erro: erro,
        dataInicial: dataInicial ?? this.dataInicial,
        dataFinal: dataFinal ?? this.dataFinal,
        comparativoStep: comparativoStep ?? this.comparativoStep,
        comparativoDados: comparativoDados ?? this.comparativoDados,
        agruparPor: agruparPor ?? this.agruparPor,
      );
}

(String, String) _mesAtual() {
  final now = DateTime.now();
  final ultimo = DateTime(now.year, now.month + 1, 0).day;
  final m = now.month.toString().padLeft(2, '0');
  return (
    '${now.year}-$m-01',
    '${now.year}-$m-${ultimo.toString().padLeft(2, '0')}',
  );
}
