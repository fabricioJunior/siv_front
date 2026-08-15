part of 'ecommerces_bloc.dart';

sealed class EcommercesEvent extends Equatable {
  const EcommercesEvent();

  @override
  List<Object?> get props => [];
}

class EcommercesCarregarSolicitado extends EcommercesEvent {
  final bool? incluirApagados;

  const EcommercesCarregarSolicitado({this.incluirApagados});

  @override
  List<Object?> get props => [incluirApagados];
}

class EcommercesExcluirSolicitado extends EcommercesEvent {
  final int id;

  const EcommercesExcluirSolicitado({required this.id});

  @override
  List<Object?> get props => [id];
}

class EcommercesRestaurarSolicitado extends EcommercesEvent {
  final int id;

  const EcommercesRestaurarSolicitado({required this.id});

  @override
  List<Object?> get props => [id];
}
