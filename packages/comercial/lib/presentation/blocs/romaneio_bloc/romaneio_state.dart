part of 'romaneio_bloc.dart';

class RomaneioState extends Equatable {
  final int? id;
  final int? pessoaId;
  final int? funcionarioId;
  final int? tabelaPrecoId;
  final TipoOperacao? operacao;
  final String? observacao;
  final List<RomaneioItem> itens;
  final List<RomaneioItemDevolvido> itensDevolvidos;
  final Romaneio? romaneio;
  final bool possuiPendenciaDeEnvio;
  final int quantidadeItensPendentes;
  final String? hashListaPendente;
  final int? documentoFiscalEmitidoId;
  // Ultimo documento fiscal do romaneio, seja qual for o status -- usado
  // pra decidir entre "Imprimir Nota Fiscal" (emitida) e "Imprimir
  // Romaneio" (falha na emissao, sem DANFE pra imprimir).
  final DocumentoFiscal? documentoFiscal;
  final String? erro;
  final RomaneioStep step;

  bool get documentoFiscalFalhou => documentoFiscal?.status == 'falha';

  const RomaneioState({
    this.id,
    this.pessoaId,
    this.funcionarioId,
    this.tabelaPrecoId,
    this.operacao,
    this.observacao,
    this.itens = const [],
    this.itensDevolvidos = const [],
    this.romaneio,
    this.possuiPendenciaDeEnvio = false,
    this.quantidadeItensPendentes = 0,
    this.hashListaPendente,
    this.documentoFiscalEmitidoId,
    this.documentoFiscal,
    this.erro,
    required this.step,
  });

  const RomaneioState.initial()
      : id = null,
        pessoaId = null,
        funcionarioId = null,
        tabelaPrecoId = null,
        operacao = TipoOperacao.venda,
        observacao = '',
        itens = const [],
        itensDevolvidos = const [],
        romaneio = null,
        possuiPendenciaDeEnvio = false,
        quantidadeItensPendentes = 0,
        hashListaPendente = null,
        documentoFiscalEmitidoId = null,
        documentoFiscal = null,
        erro = null,
        step = RomaneioStep.inicial;

  RomaneioState.fromModel(
    Romaneio model, {
    List<RomaneioItem> itensDoRomaneio = const [],
    List<RomaneioItemDevolvido> itensDevolvidos = const [],
    RomaneioStep? step,
  })  : id = model.id,
        pessoaId = model.pessoaId,
        funcionarioId = model.funcionarioId,
        tabelaPrecoId = model.tabelaPrecoId,
        operacao = model.operacao ?? TipoOperacao.venda,
        observacao = model.observacao ?? '',
        itens = itensDoRomaneio,
        itensDevolvidos = itensDevolvidos,
        romaneio = model,
        possuiPendenciaDeEnvio = false,
        quantidadeItensPendentes = 0,
        hashListaPendente = null,
        documentoFiscalEmitidoId = null,
        documentoFiscal = null,
        erro = null,
        step = step ?? RomaneioStep.editando;

  RomaneioState copyWith({
    int? id,
    int? pessoaId,
    int? funcionarioId,
    int? tabelaPrecoId,
    TipoOperacao? operacao,
    String? observacao,
    List<RomaneioItem>? itens,
    List<RomaneioItemDevolvido>? itensDevolvidos,
    Romaneio? romaneio,
    bool? possuiPendenciaDeEnvio,
    int? quantidadeItensPendentes,
    String? hashListaPendente,
    int? documentoFiscalEmitidoId,
    DocumentoFiscal? documentoFiscal,
    String? erro,
    RomaneioStep? step,
  }) {
    return RomaneioState(
      id: id ?? this.id,
      pessoaId: pessoaId ?? this.pessoaId,
      funcionarioId: funcionarioId ?? this.funcionarioId,
      tabelaPrecoId: tabelaPrecoId ?? this.tabelaPrecoId,
      operacao: operacao ?? this.operacao,
      observacao: observacao ?? this.observacao,
      itens: itens ?? this.itens,
      itensDevolvidos: itensDevolvidos ?? this.itensDevolvidos,
      romaneio: romaneio ?? this.romaneio,
      possuiPendenciaDeEnvio:
          possuiPendenciaDeEnvio ?? this.possuiPendenciaDeEnvio,
      quantidadeItensPendentes:
          quantidadeItensPendentes ?? this.quantidadeItensPendentes,
      hashListaPendente: hashListaPendente ?? this.hashListaPendente,
      documentoFiscalEmitidoId:
          documentoFiscalEmitidoId ?? this.documentoFiscalEmitidoId,
      documentoFiscal: documentoFiscal ?? this.documentoFiscal,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pessoaId,
        funcionarioId,
        tabelaPrecoId,
        operacao,
        observacao,
        itens,
        itensDevolvidos,
        romaneio,
        possuiPendenciaDeEnvio,
        quantidadeItensPendentes,
        hashListaPendente,
        documentoFiscalEmitidoId,
        documentoFiscal,
        erro,
        step,
      ];
}

enum RomaneioStep {
  inicial,
  carregando,
  editando,
  salvando,
  processando,
  criado,
  salvo,
  observacaoAtualizada,
  vendedorAtualizado,
  formaDePagamentoCorrigida,
  pagamentoRecebido,
  envioPendenciaConcluido,
  envioPendenciaIncompleto,
  validacaoInvalida,
  falha,
}
