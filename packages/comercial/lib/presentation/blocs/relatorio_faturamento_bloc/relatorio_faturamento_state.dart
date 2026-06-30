part of 'relatorio_faturamento_bloc.dart';

enum RelatorioFaturamentoStep { inicial, carregando, sucesso, falha }

class RelatorioFaturamentoState {
  final RelatorioFaturamentoStep step;
  final RelatorioFaturamento? dados;
  final String? erro;
  final String dataInicial;
  final String dataFinal;

  const RelatorioFaturamentoState({
    required this.step,
    this.dados,
    this.erro,
    required this.dataInicial,
    required this.dataFinal,
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
  }) =>
      RelatorioFaturamentoState(
        step: step ?? this.step,
        dados: dados ?? this.dados,
        erro: erro,
        dataInicial: dataInicial ?? this.dataInicial,
        dataFinal: dataFinal ?? this.dataFinal,
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
