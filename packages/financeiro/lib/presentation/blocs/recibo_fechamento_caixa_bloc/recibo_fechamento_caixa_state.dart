part of 'recibo_fechamento_caixa_bloc.dart';

enum ReciboFechamentoCaixaStep { carregando, sucesso, falha }

class ReciboFechamentoCaixaState extends Equatable {
  final ReciboFechamentoCaixaStep step;
  final ReciboFechamentoCaixa? recibo;
  final String? erro;

  const ReciboFechamentoCaixaState({
    required this.step,
    this.recibo,
    this.erro,
  });

  const ReciboFechamentoCaixaState.initial()
      : step = ReciboFechamentoCaixaStep.carregando,
        recibo = null,
        erro = null;

  ReciboFechamentoCaixaState copyWith({
    ReciboFechamentoCaixaStep? step,
    ReciboFechamentoCaixa? recibo,
    String? erro,
  }) {
    return ReciboFechamentoCaixaState(
      step: step ?? this.step,
      recibo: recibo ?? this.recibo,
      erro: erro,
    );
  }

  @override
  List<Object?> get props => [step, recibo, erro];

  @override
  bool? get stringify => true;
}
