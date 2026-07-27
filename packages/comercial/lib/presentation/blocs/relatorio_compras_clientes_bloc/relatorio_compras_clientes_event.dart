part of 'relatorio_compras_clientes_bloc.dart';

abstract class RelatorioComprasClientesEvent {}

class RelatorioComprasClientesCarregar extends RelatorioComprasClientesEvent {
  final String dataInicial;
  final String dataFinal;
  final String agruparPor;
  final List<int>? produtoIds;
  final List<int>? referenciaIds;
  final List<int>? categoriaIds;
  final List<int>? corIds;
  final List<int>? tamanhoIds;
  final int page;

  RelatorioComprasClientesCarregar({
    required this.dataInicial,
    required this.dataFinal,
    this.agruparPor = 'produto',
    this.produtoIds,
    this.referenciaIds,
    this.categoriaIds,
    this.corIds,
    this.tamanhoIds,
    this.page = 1,
  });
}
