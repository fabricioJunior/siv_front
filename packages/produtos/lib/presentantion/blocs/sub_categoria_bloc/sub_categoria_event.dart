part of 'sub_categoria_bloc.dart';

abstract class SubCategoriaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubCategoriaIniciou extends SubCategoriaEvent {
  final int categoriaId;
  final int? idSubCategoria;

  SubCategoriaIniciou({required this.categoriaId, this.idSubCategoria});

  @override
  List<Object?> get props => [categoriaId, idSubCategoria];
}

class SubCategoriaEditou extends SubCategoriaEvent {
  final String nome;
  final String? ncm;

  SubCategoriaEditou({required this.nome, this.ncm});

  @override
  List<Object?> get props => [nome, ncm];
}

class SubCategoriaSalvou extends SubCategoriaEvent {
  SubCategoriaSalvou();

  @override
  List<Object?> get props => [];
}
