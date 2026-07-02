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
  final String? ncm;

  CategoriaEditou({required this.nome, this.ncm});

  @override
  List<Object?> get props => [nome, ncm];
}

class CategoriaSalvou extends CategoriaEvent {
  CategoriaSalvou();

  @override
  List<Object?> get props => [];
}
