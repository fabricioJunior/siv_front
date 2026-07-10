part of 'consignacao_detalhe_bloc.dart';

enum ConsignacaoDetalheStep { carregando, sucesso, falha }

class ConsignacaoDetalheState extends Equatable {
  final ConsignacaoDetalheStep step;
  final Consignacao? consignacao;
  final bool processando;
  final String? erro;

  const ConsignacaoDetalheState({
    this.step = ConsignacaoDetalheStep.carregando,
    this.consignacao,
    this.processando = false,
    this.erro,
  });

  ConsignacaoDetalheState copyWith({
    ConsignacaoDetalheStep? step,
    Consignacao? consignacao,
    bool? processando,
    String? erro,
  }) {
    return ConsignacaoDetalheState(
      step: step ?? this.step,
      consignacao: consignacao ?? this.consignacao,
      processando: processando ?? this.processando,
      erro: erro,
    );
  }

  @override
  List<Object?> get props => [step, consignacao, processando, erro];
}
