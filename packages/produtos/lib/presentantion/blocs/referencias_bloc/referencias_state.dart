part of 'referencias_bloc.dart';

abstract class ReferenciasState extends Equatable {
  List<Referencia> get referencias => [];

  List<Referencia> get referenciasSelecionadas => [];
  ReferenciasOrdenacao get ordenacao => ReferenciasOrdenacao.nomeAsc;
  const ReferenciasState();

  @override
  List<Object?> get props => [referencias, ordenacao];
}

class ReferenciasInitial extends ReferenciasState {
  const ReferenciasInitial();
}

class ReferenciasCarregarEmProgresso extends ReferenciasState {
  @override
  final ReferenciasOrdenacao ordenacao;

  const ReferenciasCarregarEmProgresso({required this.ordenacao});
}

class ReferenciasCarregarSucesso extends ReferenciasState {
  @override
  final List<Referencia> referencias;
  @override
  final List<Referencia> referenciasSelecionadas;
  @override
  final ReferenciasOrdenacao ordenacao;

  const ReferenciasCarregarSucesso({
    required this.referencias,
    this.referenciasSelecionadas = const [],
    required this.ordenacao,
  });
}

class ReferenciasCarregarFalha extends ReferenciasState {
  @override
  final ReferenciasOrdenacao ordenacao;

  const ReferenciasCarregarFalha({required this.ordenacao});
}
