part of 'referencias_bloc.dart';

abstract class ReferenciasState extends Equatable {
  List<Referencia> get referencias => [];

  const ReferenciasState();

  @override
  List<Object?> get props => [referencias];
}

class ReferenciasInitial extends ReferenciasState {
  const ReferenciasInitial();
}

class ReferenciasCarregarEmProgresso extends ReferenciasState {
  const ReferenciasCarregarEmProgresso();
}

class ReferenciasCarregarSucesso extends ReferenciasState {
  @override
  final List<Referencia> referencias;

  const ReferenciasCarregarSucesso({required this.referencias});
}

class ReferenciasCarregarFalha extends ReferenciasState {
  const ReferenciasCarregarFalha();
}
