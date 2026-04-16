part of 'fluxo_de_caixa_bloc.dart';

abstract class FluxoDeCaixaEvent extends Equatable {
  const FluxoDeCaixaEvent();

  @override
  List<Object?> get props => [];
}

class FluxoDeCaixaRecuperouCaixaAberto extends FluxoDeCaixaEvent {
  final int empresaId;
  final int terminalId;

  const FluxoDeCaixaRecuperouCaixaAberto({
    required this.empresaId,
    required this.terminalId,
  });

  @override
  List<Object?> get props => [empresaId, terminalId];
}

class FluxoDeCaixaIniciou extends FluxoDeCaixaEvent {
  final int caixaId;

  const FluxoDeCaixaIniciou({required this.caixaId});

  @override
  List<Object?> get props => [caixaId];
}

class FluxoDeCaixaAbriuCaixa extends FluxoDeCaixaEvent {
  final int empresaId;
  final int terminalId;

  const FluxoDeCaixaAbriuCaixa({
    required this.empresaId,
    required this.terminalId,
  });

  @override
  List<Object?> get props => [empresaId, terminalId];
}

class FluxoDeCaixaFiltrouDocumento extends FluxoDeCaixaEvent {
  final String documento;

  const FluxoDeCaixaFiltrouDocumento({required this.documento});

  @override
  List<Object?> get props => [documento];
}
