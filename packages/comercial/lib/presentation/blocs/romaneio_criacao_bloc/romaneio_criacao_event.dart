part of 'romaneio_criacao_bloc.dart';

abstract class RomaneioCriacaoEvent extends Equatable {
  const RomaneioCriacaoEvent();

  @override
  List<Object?> get props => [];
}

class RomaneioCriacaoSolicitada extends RomaneioCriacaoEvent {
  final String hashLista;
  final List<Map<String, dynamic>> formasDePagamentoRealizadas;
  final double desconto;

  const RomaneioCriacaoSolicitada({
    required this.hashLista,
    this.formasDePagamentoRealizadas = const [],
    this.desconto = 0,
  });

  @override
  List<Object?> get props => [hashLista, formasDePagamentoRealizadas, desconto];
}
