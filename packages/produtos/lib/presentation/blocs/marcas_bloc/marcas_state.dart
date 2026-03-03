part of 'marcas_bloc.dart';

abstract class MarcasState extends Equatable {
  List<Marca> get marcas => [];

  const MarcasState();

  @override
  List<Object?> get props => [marcas];
}

class MarcasInitial extends MarcasState {
  const MarcasInitial();
}

class MarcasCarregarEmProgresso extends MarcasState {
  const MarcasCarregarEmProgresso();
}

class MarcasCarregarSucesso extends MarcasState {
  @override
  final List<Marca> marcas;

  const MarcasCarregarSucesso({required this.marcas});
}

class MarcasCarregarFalha extends MarcasState {
  const MarcasCarregarFalha();
}

class MarcasDesativarEmProgresso extends MarcasState {
  @override
  final List<Marca> marcas;

  const MarcasDesativarEmProgresso({required this.marcas});
}

class MarcasDesativarSucesso extends MarcasState {
  @override
  final List<Marca> marcas;

  const MarcasDesativarSucesso({required this.marcas});
}

class MarcasDesativarFalha extends MarcasState {
  @override
  final List<Marca> marcas;

  const MarcasDesativarFalha({required this.marcas});
}
