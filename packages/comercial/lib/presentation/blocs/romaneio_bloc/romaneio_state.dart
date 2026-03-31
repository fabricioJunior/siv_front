part of 'romaneio_bloc.dart';

class RomaneioState extends Equatable {
  final int? id;
  final String? pessoaId;
  final String? funcionarioId;
  final String? tabelaPrecoId;
  final String? operacao;
  final String? observacao;
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
    this.romaneio,
    this.erro,
    required this.step,
  });

  const RomaneioState.initial()
      : id = null,
        pessoaId = '',
        funcionarioId = '',
        tabelaPrecoId = '',
        operacao = 'venda',
        observacao = '',
        romaneio = null,
        erro = null,
        step = RomaneioStep.inicial;

  RomaneioState.fromModel(
    Romaneio model, {
    RomaneioStep? step,
  })  : id = model.id,
        pessoaId = (model.pessoaId ?? '').toString(),
        funcionarioId = (model.funcionarioId ?? '').toString(),
        tabelaPrecoId = (model.tabelaPrecoId ?? '').toString(),
        operacao = model.operacao ?? 'venda',
        observacao = model.observacao ?? '',
        romaneio = model,
        erro = null,
        step = step ?? RomaneioStep.editando;

  RomaneioState copyWith({
    int? id,
    String? pessoaId,
    String? funcionarioId,
    String? tabelaPrecoId,
    String? operacao,
    String? observacao,
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
