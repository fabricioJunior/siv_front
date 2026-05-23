part of 'sangrias_bloc.dart';

abstract class SangriasEvent extends Equatable {
  const SangriasEvent();

  @override
  List<Object?> get props => [];
}

class SangriasIniciou extends SangriasEvent {
  final int caixaId;

  const SangriasIniciou({required this.caixaId});

  @override
  List<Object?> get props => [caixaId];
}

class SangriasRecarregarSolicitado extends SangriasEvent {}

class SangriaExclusaoSolicitada extends SangriasEvent {
  final int sangriaId;
  final String motivo;

  const SangriaExclusaoSolicitada({
    required this.sangriaId,
    required this.motivo,
  });

  @override
  List<Object?> get props => [sangriaId, motivo];
}
