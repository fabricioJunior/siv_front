part of 'relatorio_fiscal_bloc.dart';

abstract class RelatorioFiscalEvent {}

class RelatorioFiscalCarregar extends RelatorioFiscalEvent {
  final int? romaneioId;
  final int? pedidoId;
  final String? cliente;
  final String? status;
  final String? formaPagamento;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final int page;

  RelatorioFiscalCarregar({
    this.romaneioId,
    this.pedidoId,
    this.cliente,
    this.status,
    this.formaPagamento,
    this.dataInicio,
    this.dataFim,
    this.page = 1,
  });
}
