part of 'relatorio_produtos_defasados_bloc.dart';

abstract class RelatorioProdutosDefasadosEvent {}

class RelatorioProdutosDefasadosCarregar
    extends RelatorioProdutosDefasadosEvent {
  final int dias;
  final String tipoMovimentacao;
  final String visualizacao;
  final String? dataReferencia;
  final String? busca;
  final int page;

  RelatorioProdutosDefasadosCarregar({
    this.dias = 90,
    this.tipoMovimentacao = 'ambas',
    this.visualizacao = 'produto',
    this.dataReferencia,
    this.busca,
    this.page = 1,
  });
}
