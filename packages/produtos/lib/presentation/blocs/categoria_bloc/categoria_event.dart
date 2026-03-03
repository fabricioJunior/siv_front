part of 'categoria_bloc.dart';

abstract class CategoriaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoriaIniciou extends CategoriaEvent {
  final int? idCategoria;

  CategoriaIniciou({this.idCategoria});

  @override
  List<Object?> get props => [idCategoria];
}

class CategoriaEditou extends CategoriaEvent {
  final String nome;

  CategoriaEditou({required this.nome});

  @override
  List<Object?> get props => [nome];
}

class CategoriaSalvou extends CategoriaEvent {
  CategoriaSalvou();

  @override
  List<Object?> get props => [];
}
