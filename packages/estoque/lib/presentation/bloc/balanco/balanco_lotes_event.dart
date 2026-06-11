part of 'balanco_lotes_bloc.dart';

sealed class BalancoLotesEvent extends Equatable {
  const BalancoLotesEvent();

  @override
  List<Object?> get props => [];
}

class CarregarLotesDoBalancoEvent extends BalancoLotesEvent {
  final int balancoId;

  const CarregarLotesDoBalancoEvent({required this.balancoId});

  @override
  List<Object?> get props => [balancoId];
}
