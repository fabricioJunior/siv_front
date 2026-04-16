part of 'suprimentos_bloc.dart';

class SuprimentosState extends Equatable {
  final int? caixaId;
  final List<Suprimento> suprimentos;
  final String? erro;
  final SuprimentosStep step;

  const SuprimentosState({
    this.caixaId,
    this.suprimentos = const [],
    this.erro,
    required this.step,
  });

  const SuprimentosState.initial()
      : caixaId = null,
        suprimentos = const [],
        erro = null,
        step = SuprimentosStep.inicial;

  SuprimentosState copyWith({
    int? caixaId,
    List<Suprimento>? suprimentos,
    String? erro,
    SuprimentosStep? step,
  }) {
    return SuprimentosState(
      caixaId: caixaId ?? this.caixaId,
      suprimentos: suprimentos ?? this.suprimentos,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [caixaId, suprimentos, erro, step];
}

enum SuprimentosStep {
  inicial,
  carregando,
  sucesso,
  cancelando,
  cancelado,
  falha,
}
