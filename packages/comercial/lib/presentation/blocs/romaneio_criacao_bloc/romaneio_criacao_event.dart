part of 'romaneio_criacao_bloc.dart';

abstract class RomaneioCriacaoEvent extends Equatable {
  const RomaneioCriacaoEvent();

  @override
  List<Object?> get props => [];
}

class RomaneioCriacaoSolicitada extends RomaneioCriacaoEvent {
  final String hashLista;
  final List<Map<String, dynamic>> formasDePagamentoRealizadas;

  const RomaneioCriacaoSolicitada({
    required this.hashLista,
    this.formasDePagamentoRealizadas = const [],
  });

  @override
  List<Object?> get props => [hashLista, formasDePagamentoRealizadas];
}
