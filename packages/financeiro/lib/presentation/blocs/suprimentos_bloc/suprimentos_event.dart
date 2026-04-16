part of 'suprimentos_bloc.dart';

abstract class SuprimentosEvent extends Equatable {
  const SuprimentosEvent();

  @override
  List<Object?> get props => [];
}

class SuprimentosIniciou extends SuprimentosEvent {
  final int caixaId;

  const SuprimentosIniciou({required this.caixaId});

  @override
  List<Object?> get props => [caixaId];
}

class SuprimentosRecarregarSolicitado extends SuprimentosEvent {}

class SuprimentoExclusaoSolicitada extends SuprimentosEvent {
  final int suprimentoId;
  final String motivo;

  const SuprimentoExclusaoSolicitada({
    required this.suprimentoId,
    required this.motivo,
  });

  @override
  List<Object?> get props => [suprimentoId, motivo];
}
