part of 'listas_personalizadas_bloc.dart';

abstract class ListasPersonalizadasEvent extends Equatable {
  const ListasPersonalizadasEvent();

  @override
  List<Object?> get props => [];
}

class ListasPersonalizadasIniciou extends ListasPersonalizadasEvent {}

class ListasPersonalizadasCarregarMaisSolicitado extends ListasPersonalizadasEvent {}
