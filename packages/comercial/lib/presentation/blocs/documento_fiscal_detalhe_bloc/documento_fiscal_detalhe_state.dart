part of 'documento_fiscal_detalhe_bloc.dart';

enum DocumentoFiscalDetalheStep { inicial, carregando, sucesso, falha }

class DocumentoFiscalDetalheState {
  final DocumentoFiscalDetalheStep step;
  final DocumentoFiscalDetalhe? detalhe;
  final String? erro;

  const DocumentoFiscalDetalheState({
    this.step = DocumentoFiscalDetalheStep.inicial,
    this.detalhe,
    this.erro,
  });

  DocumentoFiscalDetalheState copyWith({
    DocumentoFiscalDetalheStep? step,
    DocumentoFiscalDetalhe? detalhe,
    String? erro,
  }) =>
      DocumentoFiscalDetalheState(
        step: step ?? this.step,
        detalhe: detalhe ?? this.detalhe,
        erro: erro ?? this.erro,
      );
}
