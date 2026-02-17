part of 'categorias_bloc.dart';

abstract class CategoriasState extends Equatable {
  List<Categoria> get categorias => [];

  const CategoriasState();

  @override
  List<Object?> get props => [categorias];
}

class CategoriasInitial extends CategoriasState {
  const CategoriasInitial();
}

class CategoriasCarregarEmProgresso extends CategoriasState {
  const CategoriasCarregarEmProgresso();
}

class CategoriasCarregarSucesso extends CategoriasState {
  @override
  final List<Categoria> categorias;

  const CategoriasCarregarSucesso({required this.categorias});
}

class CategoriasCarregarFalha extends CategoriasState {
  const CategoriasCarregarFalha();
}

class CategoriasDesativarEmProgresso extends CategoriasState {
  @override
  final List<Categoria> categorias;

  const CategoriasDesativarEmProgresso({required this.categorias});
}

class CategoriasDesativarSucesso extends CategoriasState {
  @override
  final List<Categoria> categorias;

  const CategoriasDesativarSucesso({required this.categorias});
}

class CategoriasDesativarFalha extends CategoriasState {
  @override
  final List<Categoria> categorias;

  const CategoriasDesativarFalha({required this.categorias});
}
