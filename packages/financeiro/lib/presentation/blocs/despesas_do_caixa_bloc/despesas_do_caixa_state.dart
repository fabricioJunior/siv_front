part of 'despesas_do_caixa_bloc.dart';

class DespesasDoCaixaState extends Equatable {
  final int? caixaId;
  final List<DespesaDoCaixa> despesas;
  final String? erro;
  final DespesasDoCaixaStep step;

  const DespesasDoCaixaState({
    this.caixaId,
    this.despesas = const [],
    this.erro,
    required this.step,
  });

  const DespesasDoCaixaState.initial()
      : caixaId = null,
        despesas = const [],
        erro = null,
        step = DespesasDoCaixaStep.inicial;

  DespesasDoCaixaState copyWith({
    int? caixaId,
    List<DespesaDoCaixa>? despesas,
    String? erro,
    DespesasDoCaixaStep? step,
  }) {
    return DespesasDoCaixaState(
      caixaId: caixaId ?? this.caixaId,
      despesas: despesas ?? this.despesas,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [caixaId, despesas, erro, step];
}

enum DespesasDoCaixaStep {
  inicial,
  carregando,
  sucesso,
  cancelando,
  cancelado,
  falha,
}
