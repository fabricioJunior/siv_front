part of 'fechamento_de_caixa_bloc.dart';

abstract class FechamentoDeCaixaEvent extends Equatable {
  const FechamentoDeCaixaEvent();

  @override
  List<Object?> get props => [];
}

class FechamentoDeCaixaIniciou extends FechamentoDeCaixaEvent {
  final int caixaId;

  const FechamentoDeCaixaIniciou({required this.caixaId});

  @override
  List<Object?> get props => [caixaId];
}

class FechamentoDeCaixaRecarregarSolicitado extends FechamentoDeCaixaEvent {
  final int caixaId;

  const FechamentoDeCaixaRecarregarSolicitado({required this.caixaId});

  @override
  List<Object?> get props => [caixaId];
}
