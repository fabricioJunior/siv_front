part of 'romaneio_bloc.dart';

class RomaneioState extends Equatable {
  final int? id;
  final int? pessoaId;
  final int? funcionarioId;
  final int? tabelaPrecoId;
  final TipoOperacao? operacao;
  final String? observacao;
  final List<RomaneioItem> itens;
  final Romaneio? romaneio;
  final String? erro;
  final RomaneioStep step;

  const RomaneioState({
    this.id,
    this.pessoaId,
    this.funcionarioId,
    this.tabelaPrecoId,
    this.operacao,
    this.observacao,
    this.itens = const [],
    this.romaneio,
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
        romaneio = null,
        erro = null,
        step = RomaneioStep.inicial;

  RomaneioState.fromModel(
    Romaneio model, {
    List<RomaneioItem> itensDoRomaneio = const [],
    RomaneioStep? step,
  })  : id = model.id,
        pessoaId = model.pessoaId,
        funcionarioId = model.funcionarioId,
        tabelaPrecoId = model.tabelaPrecoId,
        operacao = model.operacao ?? TipoOperacao.venda,
        observacao = model.observacao ?? '',
        itens = itensDoRomaneio,
        romaneio = model,
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
    Romaneio? romaneio,
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
      romaneio: romaneio ?? this.romaneio,
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
        romaneio,
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
  validacaoInvalida,
  falha,
}
