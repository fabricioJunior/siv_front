part of 'estampas_bloc.dart';

abstract class EstampasEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EstampasIniciou extends EstampasEvent {
  final String? busca;
  final bool? inativo;

  EstampasIniciou({this.busca, this.inativo});

  @override
  List<Object?> get props => [busca, inativo];
}

class EstampasDesativar extends EstampasEvent {
  final int id;

  EstampasDesativar({required this.id});

  @override
  List<Object?> get props => [id];
}
