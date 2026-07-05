part of 'relatorio_vendas_por_funcionario_bloc.dart';

abstract class RelatorioVendasPorFuncionarioEvent {}

class RelatorioVendasPorFuncionarioCarregar
    extends RelatorioVendasPorFuncionarioEvent {
  final List<SelectData> funcionariosSelecionados;
  final String dataInicial;
  final String dataFinal;

  RelatorioVendasPorFuncionarioCarregar({
    required this.funcionariosSelecionados,
    required this.dataInicial,
    required this.dataFinal,
  });
}
