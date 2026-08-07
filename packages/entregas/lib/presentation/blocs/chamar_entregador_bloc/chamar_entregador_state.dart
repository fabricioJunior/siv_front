part of 'chamar_entregador_bloc.dart';

class ChamarEntregadorState extends Equatable {
  final double? saldo;
  final EnderecoEntrega? partida;
  final EnderecoEntrega? destino;
  final ParadaEntrega? parada;
  final EstimativaEntrega? estimativa;
  final SolicitacaoEntrega? solicitacao;
  final List<RastreioEntrega>? rastreio;
  final String? erro;
  final ChamarEntregadorStep step;

  const ChamarEntregadorState({
    this.saldo,
    this.partida,
    this.destino,
    this.parada,
    this.estimativa,
    this.solicitacao,
    this.rastreio,
    this.erro,
    required this.step,
  });

  const ChamarEntregadorState.initial()
      : saldo = null,
        partida = null,
        destino = null,
        parada = null,
        estimativa = null,
        solicitacao = null,
        rastreio = null,
        erro = null,
        step = ChamarEntregadorStep.formulario;

  ChamarEntregadorState copyWith({
    double? saldo,
    EnderecoEntrega? partida,
    EnderecoEntrega? destino,
    ParadaEntrega? parada,
    EstimativaEntrega? estimativa,
    SolicitacaoEntrega? solicitacao,
    List<RastreioEntrega>? rastreio,
    String? erro,
    ChamarEntregadorStep? step,
  }) {
    return ChamarEntregadorState(
      saldo: saldo ?? this.saldo,
      partida: partida ?? this.partida,
      destino: destino ?? this.destino,
      parada: parada ?? this.parada,
      estimativa: estimativa ?? this.estimativa,
      solicitacao: solicitacao ?? this.solicitacao,
      rastreio: rastreio ?? this.rastreio,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        saldo,
        partida,
        destino,
        parada,
        estimativa,
        solicitacao,
        rastreio,
        erro,
        step,
      ];
}

enum ChamarEntregadorStep {
  formulario,
  estimando,
  estimado,
  chamando,
  chamado,
  obtendoRastreio,
  cancelando,
  cancelado,
  falha,
}
