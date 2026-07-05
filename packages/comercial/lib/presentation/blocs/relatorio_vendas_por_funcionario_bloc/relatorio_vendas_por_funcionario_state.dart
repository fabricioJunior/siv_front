part of 'relatorio_vendas_por_funcionario_bloc.dart';

enum RelatorioVendasPorFuncionarioStep { inicial, carregando, sucesso, falha }

class RelatorioVendasPorFuncionarioState {
  final RelatorioVendasPorFuncionarioStep step;
  final List<RelatorioVendasPorFuncionarioItem> dados;
  final List<SelectData> funcionariosSelecionados;
  final String? erro;
  final String dataInicial;
  final String dataFinal;

  const RelatorioVendasPorFuncionarioState({
    required this.step,
    this.dados = const [],
    this.funcionariosSelecionados = const [],
    this.erro,
    required this.dataInicial,
    required this.dataFinal,
  });

  factory RelatorioVendasPorFuncionarioState.initial() {
    final (ini, fim) = _mesAtualVendasPorFuncionario();
    return RelatorioVendasPorFuncionarioState(
      step: RelatorioVendasPorFuncionarioStep.inicial,
      dataInicial: ini,
      dataFinal: fim,
    );
  }

  RelatorioVendasPorFuncionarioState copyWith({
    RelatorioVendasPorFuncionarioStep? step,
    List<RelatorioVendasPorFuncionarioItem>? dados,
    List<SelectData>? funcionariosSelecionados,
    String? erro,
    String? dataInicial,
    String? dataFinal,
  }) =>
      RelatorioVendasPorFuncionarioState(
        step: step ?? this.step,
        dados: dados ?? this.dados,
        funcionariosSelecionados:
            funcionariosSelecionados ?? this.funcionariosSelecionados,
        erro: erro,
        dataInicial: dataInicial ?? this.dataInicial,
        dataFinal: dataFinal ?? this.dataFinal,
      );
}

(String, String) _mesAtualVendasPorFuncionario() {
  final now = DateTime.now();
  final ultimo = DateTime(now.year, now.month + 1, 0).day;
  final m = now.month.toString().padLeft(2, '0');
  return (
    '${now.year}-$m-01',
    '${now.year}-$m-${ultimo.toString().padLeft(2, '0')}',
  );
}
