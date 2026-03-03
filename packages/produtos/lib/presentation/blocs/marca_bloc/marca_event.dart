part of 'marca_bloc.dart';

abstract class MarcaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MarcaIniciou extends MarcaEvent {
  final int? idMarca;

  MarcaIniciou({this.idMarca});

  @override
  List<Object?> get props => [idMarca];
}

class MarcaEditou extends MarcaEvent {
  final String nome;

  MarcaEditou({required this.nome});

  @override
  List<Object?> get props => [nome];
}

class MarcaSalvou extends MarcaEvent {
  MarcaSalvou();

  @override
  List<Object?> get props => [];
}
