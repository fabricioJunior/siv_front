part of 'romaneio_criacao_bloc.dart';

enum RomaneioCriacaoStep { inicial, processando, sucesso, falha }

class RomaneioCriacaoState extends Equatable {
  final RomaneioCriacaoStep step;
  final String? hashLista;
  final ListaDeProdutosCompartilhada? listaCompartilhada;
  final List<ProdutoCompartilhado> produtosCompartilhados;
  final Romaneio? romaneio;
  final String? erro;
  final int totalItensProcessados;
  // Ultimo documento fiscal do romaneio recem criado, se houver (qualquer
  // status) -- usado pela tela de sucesso pra decidir entre "Imprimir Nota
  // Fiscal" (emitida) e "Imprimir Romaneio" (falha na emissao).
  final DocumentoFiscal? documentoFiscal;
  // Itens efetivamente enviados ao romaneio, usados como fallback de
  // impressao do romaneio quando nao ha nota fiscal emitida.
  final List<RomaneioItem> itensCriados;

  const RomaneioCriacaoState({
    required this.step,
    this.hashLista,
    this.listaCompartilhada,
    this.produtosCompartilhados = const [],
    this.romaneio,
    this.erro,
    this.totalItensProcessados = 0,
    this.documentoFiscal,
    this.itensCriados = const [],
  });

  const RomaneioCriacaoState.initial()
      : step = RomaneioCriacaoStep.inicial,
        hashLista = null,
        listaCompartilhada = null,
        produtosCompartilhados = const [],
        romaneio = null,
        erro = null,
        totalItensProcessados = 0,
        documentoFiscal = null,
        itensCriados = const [];

  RomaneioCriacaoState copyWith({
    RomaneioCriacaoStep? step,
    String? hashLista,
    ListaDeProdutosCompartilhada? listaCompartilhada,
    List<ProdutoCompartilhado>? produtosCompartilhados,
    Romaneio? romaneio,
    String? erro,
    int? totalItensProcessados,
    DocumentoFiscal? documentoFiscal,
    List<RomaneioItem>? itensCriados,
  }) {
    return RomaneioCriacaoState(
      step: step ?? this.step,
      hashLista: hashLista ?? this.hashLista,
      listaCompartilhada: listaCompartilhada ?? this.listaCompartilhada,
      produtosCompartilhados:
          produtosCompartilhados ?? this.produtosCompartilhados,
      romaneio: romaneio ?? this.romaneio,
      erro: erro ?? this.erro,
      totalItensProcessados:
          totalItensProcessados ?? this.totalItensProcessados,
      documentoFiscal: documentoFiscal ?? this.documentoFiscal,
      itensCriados: itensCriados ?? this.itensCriados,
    );
  }

  @override
  List<Object?> get props => [
        step,
        hashLista,
        listaCompartilhada,
        produtosCompartilhados,
        romaneio,
        erro,
        totalItensProcessados,
        documentoFiscal,
        itensCriados,
      ];
}
