part of 'sangrias_bloc.dart';

class SangriasState extends Equatable {
  final int? caixaId;
  final List<Sangria> sangrias;
  final String? erro;
  final SangriasStep step;

  const SangriasState({
    this.caixaId,
    this.sangrias = const [],
    this.erro,
    required this.step,
  });

  const SangriasState.initial()
      : caixaId = null,
        sangrias = const [],
        erro = null,
        step = SangriasStep.inicial;

  SangriasState copyWith({
    int? caixaId,
    List<Sangria>? sangrias,
    String? erro,
    SangriasStep? step,
  }) {
    return SangriasState(
      caixaId: caixaId ?? this.caixaId,
      sangrias: sangrias ?? this.sangrias,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [caixaId, sangrias, erro, step];
}

enum SangriasStep {
  inicial,
  carregando,
  sucesso,
  cancelando,
  cancelado,
  falha,
}
