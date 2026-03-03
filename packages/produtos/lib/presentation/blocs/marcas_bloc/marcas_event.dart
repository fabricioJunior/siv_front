part of 'marcas_bloc.dart';

abstract class MarcasEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MarcasIniciou extends MarcasEvent {
  final String? busca;
  final bool? inativa;

  MarcasIniciou({this.busca, this.inativa});

  @override
  List<Object?> get props => [busca, inativa];
}

class MarcasDesativar extends MarcasEvent {
  final int id;

  MarcasDesativar({required this.id});

  @override
  List<Object?> get props => [id];
}
