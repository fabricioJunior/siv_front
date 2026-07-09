part of 'orcamentos_bloc.dart';

sealed class OrcamentosEvent extends Equatable {
  const OrcamentosEvent();

  @override
  List<Object?> get props => [];
}

class OrcamentosCarregarSolicitado extends OrcamentosEvent {
  const OrcamentosCarregarSolicitado();
}

class OrcamentoExcluirSolicitado extends OrcamentosEvent {
  final String hash;

  const OrcamentoExcluirSolicitado({required this.hash});

  @override
  List<Object?> get props => [hash];
}
