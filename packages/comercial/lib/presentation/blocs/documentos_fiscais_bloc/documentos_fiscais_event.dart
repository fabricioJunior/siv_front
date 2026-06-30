part of 'documentos_fiscais_bloc.dart';

abstract class DocumentosFiscaisEvent {}

class DocumentosFiscaisCarregar extends DocumentosFiscaisEvent {
  final int? romaneioId;
  final int? pedidoId;
  final String? cliente;
  final String? status;
  final String? formaPagamento;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final int page;

  DocumentosFiscaisCarregar({
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

class DocumentosFiscaisReprocessar extends DocumentosFiscaisEvent {
  final int id;
  DocumentosFiscaisReprocessar(this.id);
}
