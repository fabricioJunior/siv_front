part of 'romaneio_criacao_bloc.dart';

abstract class RomaneioCriacaoEvent extends Equatable {
  const RomaneioCriacaoEvent();

  @override
  List<Object?> get props => [];
}

class RomaneioCriacaoSolicitada extends RomaneioCriacaoEvent {
  final String hashLista;

  const RomaneioCriacaoSolicitada({required this.hashLista});

  @override
  List<Object?> get props => [hashLista];
}
