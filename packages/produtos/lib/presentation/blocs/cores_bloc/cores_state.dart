part of 'cores_bloc.dart';

abstract class CoresState extends Equatable {
  List<Cor> get cores => [];

  const CoresState();

  @override
  List<Object?> get props => [cores];
}

class CoresInitial extends CoresState {
  const CoresInitial();
}

class CoresCarregarEmProgresso extends CoresState {
  const CoresCarregarEmProgresso();
}

class CoresCarregarSucesso extends CoresState {
  @override
  final List<Cor> cores;

  const CoresCarregarSucesso({required this.cores});
}

class CoresCarregarFalha extends CoresState {
  const CoresCarregarFalha();
}

class CoresDesativarEmProgresso extends CoresState {
  @override
  final List<Cor> cores;

  const CoresDesativarEmProgresso({required this.cores});
}

class CoresDesativarSucesso extends CoresState {
  @override
  final List<Cor> cores;

  const CoresDesativarSucesso({required this.cores});
}

class CoresDesativarFalha extends CoresState {
  @override
  final List<Cor> cores;

  const CoresDesativarFalha({required this.cores});
}
