part of 'relatorio_clientes_aniversariantes_bloc.dart';

abstract class RelatorioClientesAniversariantesEvent {}

class RelatorioClientesAniversariantesCarregar
    extends RelatorioClientesAniversariantesEvent {
  final int mes;
  final String? dataUltimaCompraInicial;
  final String? dataUltimaCompraFinal;
  final int page;

  RelatorioClientesAniversariantesCarregar({
    required this.mes,
    this.dataUltimaCompraInicial,
    this.dataUltimaCompraFinal,
    this.page = 1,
  });
}
