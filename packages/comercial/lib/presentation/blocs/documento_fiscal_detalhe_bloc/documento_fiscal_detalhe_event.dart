part of 'documento_fiscal_detalhe_bloc.dart';

abstract class DocumentoFiscalDetalheEvent {}

class DocumentoFiscalDetalheCarregar extends DocumentoFiscalDetalheEvent {
  final int id;
  DocumentoFiscalDetalheCarregar(this.id);
}
