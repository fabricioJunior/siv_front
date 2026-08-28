part of 'estampas_bloc.dart';

abstract class EstampasState extends Equatable {
  List<Estampa> get estampas => [];

  const EstampasState();

  @override
  List<Object?> get props => [estampas];
}

class EstampasInitial extends EstampasState {
  const EstampasInitial();
}

class EstampasCarregarEmProgresso extends EstampasState {
  const EstampasCarregarEmProgresso();
}

class EstampasCarregarSucesso extends EstampasState {
  @override
  final List<Estampa> estampas;

  const EstampasCarregarSucesso({required this.estampas});
}

class EstampasCarregarFalha extends EstampasState {
  const EstampasCarregarFalha();
}

class EstampasDesativarEmProgresso extends EstampasState {
  @override
  final List<Estampa> estampas;

  const EstampasDesativarEmProgresso({required this.estampas});
}

class EstampasDesativarSucesso extends EstampasState {
  @override
  final List<Estampa> estampas;

  const EstampasDesativarSucesso({required this.estampas});
}

class EstampasDesativarFalha extends EstampasState {
  @override
  final List<Estampa> estampas;

  const EstampasDesativarFalha({required this.estampas});
}
