part of 'sub_categorias_bloc.dart';

abstract class SubCategoriasState extends Equatable {
  List<SubCategoria> get subCategorias => [];

  const SubCategoriasState();

  @override
  List<Object?> get props => [subCategorias];
}

class SubCategoriasInitial extends SubCategoriasState {
  const SubCategoriasInitial();
}

class SubCategoriasCarregarEmProgresso extends SubCategoriasState {
  const SubCategoriasCarregarEmProgresso();
}

class SubCategoriasCarregarSucesso extends SubCategoriasState {
  @override
  final List<SubCategoria> subCategorias;

  const SubCategoriasCarregarSucesso({required this.subCategorias});
}

class SubCategoriasCarregarFalha extends SubCategoriasState {
  const SubCategoriasCarregarFalha();
}

class SubCategoriasDesativarEmProgresso extends SubCategoriasState {
  @override
  final List<SubCategoria> subCategorias;

  const SubCategoriasDesativarEmProgresso({required this.subCategorias});
}

class SubCategoriasDesativarSucesso extends SubCategoriasState {
  @override
  final List<SubCategoria> subCategorias;

  const SubCategoriasDesativarSucesso({required this.subCategorias});
}

class SubCategoriasDesativarFalha extends SubCategoriasState {
  @override
  final List<SubCategoria> subCategorias;

  const SubCategoriasDesativarFalha({required this.subCategorias});
}
