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

  SubCategoriaEditou({required this.nome});

  @override
  List<Object?> get props => [nome];
}

class SubCategoriaSalvou extends SubCategoriaEvent {
  SubCategoriaSalvou();

  @override
  List<Object?> get props => [];
}
