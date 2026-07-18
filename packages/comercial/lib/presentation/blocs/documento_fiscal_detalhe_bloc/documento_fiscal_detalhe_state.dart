part of 'documento_fiscal_detalhe_bloc.dart';

enum DocumentoFiscalDetalheStep { inicial, carregando, sucesso, falha }

class DocumentoFiscalDetalheState {
  final DocumentoFiscalDetalheStep step;
  final DocumentoFiscalDetalhe? detalhe;
  final String? erro;
  final Romaneio? romaneioParaImpressao;
  final List<RomaneioItem> itensParaImpressao;
  final List<RomaneioItemDevolvido> itensDevolvidosParaImpressao;

  const DocumentoFiscalDetalheState({
    this.step = DocumentoFiscalDetalheStep.inicial,
    this.detalhe,
    this.erro,
    this.romaneioParaImpressao,
    this.itensParaImpressao = const [],
    this.itensDevolvidosParaImpressao = const [],
  });

  DocumentoFiscalDetalheState copyWith({
    DocumentoFiscalDetalheStep? step,
    DocumentoFiscalDetalhe? detalhe,
    String? erro,
    Romaneio? romaneioParaImpressao,
    List<RomaneioItem>? itensParaImpressao,
    List<RomaneioItemDevolvido>? itensDevolvidosParaImpressao,
  }) =>
      DocumentoFiscalDetalheState(
        step: step ?? this.step,
        detalhe: detalhe ?? this.detalhe,
        erro: erro ?? this.erro,
        romaneioParaImpressao: romaneioParaImpressao ?? this.romaneioParaImpressao,
        itensParaImpressao: itensParaImpressao ?? this.itensParaImpressao,
        itensDevolvidosParaImpressao:
            itensDevolvidosParaImpressao ?? this.itensDevolvidosParaImpressao,
      );
}
