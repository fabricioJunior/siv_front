part of 'tamanhos_bloc.dart';

abstract class TamanhosEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class TamanhosIniciou extends TamanhosEvent {
  final String? busca;
  final bool? inativo;

  TamanhosIniciou({this.busca, this.inativo});

  @override
  List<Object?> get props => [busca, inativo];
}

class TamanhosDesativar extends TamanhosEvent {
  final int id;

  TamanhosDesativar({required this.id});

  @override
  List<Object?> get props => [id];
}
