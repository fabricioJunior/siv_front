part of 'cor_bloc.dart';

abstract class CorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CorIniciou extends CorEvent {
  final int? idCor;

  CorIniciou({this.idCor});

  @override
  List<Object?> get props => [idCor];
}

class CorEditou extends CorEvent {
  final String nome;

  CorEditou({required this.nome});

  @override
  List<Object?> get props => [nome];
}

class CorSalvou extends CorEvent {
  CorSalvou();

  @override
  List<Object?> get props => [];
}
