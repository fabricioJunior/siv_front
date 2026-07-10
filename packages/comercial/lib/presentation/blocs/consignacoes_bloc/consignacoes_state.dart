part of 'consignacoes_bloc.dart';

enum ConsignacoesStep { inicial, carregando, sucesso, falha }

class ConsignacoesState extends Equatable {
  final ConsignacoesStep step;
  final List<Consignacao> consignacoes;
  final String? erro;

  const ConsignacoesState({
    this.step = ConsignacoesStep.inicial,
    this.consignacoes = const [],
    this.erro,
  });

  ConsignacoesState copyWith({
    ConsignacoesStep? step,
    List<Consignacao>? consignacoes,
    String? erro,
  }) {
    return ConsignacoesState(
      step: step ?? this.step,
      consignacoes: consignacoes ?? this.consignacoes,
      erro: erro,
    );
  }

  @override
  List<Object?> get props => [step, consignacoes, erro];
}
