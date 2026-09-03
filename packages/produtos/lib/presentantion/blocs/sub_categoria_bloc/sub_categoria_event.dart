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
  final int? pesoGramas;

  SubCategoriaEditou({required this.nome, this.ncm, this.pesoGramas});

  @override
  List<Object?> get props => [nome, ncm, pesoGramas];
}

class SubCategoriaSalvou extends SubCategoriaEvent {
  SubCategoriaSalvou();

  @override
  List<Object?> get props => [];
}
