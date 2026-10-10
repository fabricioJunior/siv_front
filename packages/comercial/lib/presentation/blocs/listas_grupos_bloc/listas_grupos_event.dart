part of 'listas_grupos_bloc.dart';

abstract class ListasGruposEvent extends Equatable {
  const ListasGruposEvent();

  @override
  List<Object?> get props => [];
}

class ListasGruposIniciou extends ListasGruposEvent {
  const ListasGruposIniciou();
}

class ListasGruposExcluiu extends ListasGruposEvent {
  final int id;

  const ListasGruposExcluiu(this.id);

  @override
  List<Object?> get props => [id];
}
