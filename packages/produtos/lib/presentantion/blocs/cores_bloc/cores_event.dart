part of 'cores_bloc.dart';

abstract class CoresEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CoresIniciou extends CoresEvent {
  final String? busca;
  final bool? inativo;

  CoresIniciou({this.busca, this.inativo});

  @override
  List<Object?> get props => [busca, inativo];
}

class CoresDesativar extends CoresEvent {
  final int id;

  CoresDesativar({required this.id});

  @override
  List<Object?> get props => [id];
}
