part of 'sub_categorias_bloc.dart';

abstract class SubCategoriasEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubCategoriasIniciou extends SubCategoriasEvent {
  final int categoriaId;
  final String? busca;
  final bool? inativa;

  SubCategoriasIniciou({required this.categoriaId, this.busca, this.inativa});

  @override
  List<Object?> get props => [categoriaId, busca, inativa];
}

class SubCategoriasDesativar extends SubCategoriasEvent {
  final int categoriaId;
  final int id;

  SubCategoriasDesativar({required this.categoriaId, required this.id});

  @override
  List<Object?> get props => [categoriaId, id];
}
