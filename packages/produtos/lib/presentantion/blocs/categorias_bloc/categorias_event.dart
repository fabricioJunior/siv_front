part of 'categorias_bloc.dart';

abstract class CategoriasEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoriasIniciou extends CategoriasEvent {
  final String? busca;
  final bool? inativa;

  CategoriasIniciou({this.busca, this.inativa});

  @override
  List<Object?> get props => [busca, inativa];
}

class CategoriasDesativar extends CategoriasEvent {
  final int id;

  CategoriasDesativar({required this.id});

  @override
  List<Object?> get props => [id];
}
