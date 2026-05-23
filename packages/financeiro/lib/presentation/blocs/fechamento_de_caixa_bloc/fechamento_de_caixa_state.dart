part of 'fechamento_de_caixa_bloc.dart';

class FechamentoDeCaixaState extends Equatable {
  final int? caixaId;
  final List<ConferenciaFechamentoItem> itens;
  final String? erro;
  final FechamentoDeCaixaStep step;

  const FechamentoDeCaixaState({
    this.caixaId,
    this.itens = const [],
    this.erro,
    required this.step,
  });

  const FechamentoDeCaixaState.initial()
      : caixaId = null,
        itens = const [],
        erro = null,
        step = FechamentoDeCaixaStep.inicial;

  FechamentoDeCaixaState copyWith({
    int? caixaId,
    List<ConferenciaFechamentoItem>? itens,
    String? erro,
    FechamentoDeCaixaStep? step,
  }) {
    return FechamentoDeCaixaState(
      caixaId: caixaId ?? this.caixaId,
      itens: itens ?? this.itens,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [caixaId, itens, erro, step];
}

enum FechamentoDeCaixaStep {
  inicial,
  carregando,
  carregado,
  falha,
}

class ConferenciaFechamentoItem extends Equatable {
  final TipoContagemDoCaixaItem tipo;
  final double valorEsperado;
  final double valorContado;

  const ConferenciaFechamentoItem({
    required this.tipo,
    required this.valorEsperado,
    required this.valorContado,
  });

  @override
  List<Object?> get props => [tipo, valorEsperado, valorContado];
}
