part of 'sangria_bloc.dart';

class SangriaState extends Equatable {
  final int? caixaId;
  final String valor;
  final String descricao;
  final Sangria? sangria;
  final String? erro;
  final SangriaStep step;

  const SangriaState({
    this.caixaId,
    this.valor = '',
    this.descricao = '',
    this.sangria,
    this.erro,
    required this.step,
  });

  const SangriaState.initial()
      : caixaId = null,
        valor = '',
        descricao = '',
        sangria = null,
        erro = null,
        step = SangriaStep.inicial;

  SangriaState copyWith({
    int? caixaId,
    String? valor,
    String? descricao,
    Sangria? sangria,
    String? erro,
    SangriaStep? step,
  }) {
    return SangriaState(
      caixaId: caixaId ?? this.caixaId,
      valor: valor ?? this.valor,
      descricao: descricao ?? this.descricao,
      sangria: sangria ?? this.sangria,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [caixaId, valor, descricao, sangria, erro, step];
}

enum SangriaStep {
  inicial,
  editando,
  salvando,
  criado,
  validacaoInvalida,
  falha,
}
