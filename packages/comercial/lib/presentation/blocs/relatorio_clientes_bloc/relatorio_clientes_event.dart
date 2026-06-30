part of 'relatorio_clientes_bloc.dart';

abstract class RelatorioClientesEvent {}

class RelatorioClientesCarregar extends RelatorioClientesEvent {
  final int dias;
  final String? dataReferencia;
  final int page;

  RelatorioClientesCarregar({
    this.dias = 30,
    this.dataReferencia,
    this.page = 1,
  });
}
