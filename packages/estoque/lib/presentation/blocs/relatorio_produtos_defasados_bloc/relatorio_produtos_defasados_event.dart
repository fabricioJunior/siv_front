part of 'relatorio_produtos_defasados_bloc.dart';

abstract class RelatorioProdutosDefasadosEvent {}

class RelatorioProdutosDefasadosCarregar
    extends RelatorioProdutosDefasadosEvent {
  final int dias;
  final String tipoMovimentacao;
  final String visualizacao;
  final String? dataReferencia;
  final List<int>? corIds;
  final List<int>? tamanhoIds;
  final ModoAgrupamentoReferencia modoAgrupamentoReferencia;
  final String? busca;
  final int page;

  RelatorioProdutosDefasadosCarregar({
    this.dias = 90,
    this.tipoMovimentacao = 'ambas',
    this.visualizacao = 'produto',
    this.dataReferencia,
    this.corIds,
    this.tamanhoIds,
    this.modoAgrupamentoReferencia = ModoAgrupamentoReferencia.todos,
    this.busca,
    this.page = 1,
  });
}
