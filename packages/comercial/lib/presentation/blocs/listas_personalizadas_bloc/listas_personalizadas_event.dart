part of 'listas_personalizadas_bloc.dart';

abstract class ListasPersonalizadasEvent extends Equatable {
  const ListasPersonalizadasEvent();

  @override
  List<Object?> get props => [];
}

class ListasPersonalizadasIniciou extends ListasPersonalizadasEvent {
  /// `null` = todas as listas.
  final ListaTipo? tipo;

  const ListasPersonalizadasIniciou({this.tipo});

  @override
  List<Object?> get props => [tipo];
}

class ListasPersonalizadasCarregarMaisSolicitado extends ListasPersonalizadasEvent {}
