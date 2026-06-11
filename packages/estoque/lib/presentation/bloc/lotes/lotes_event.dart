part of 'lotes_bloc.dart';

sealed class LotesEvent extends Equatable {
  const LotesEvent();

  @override
  List<Object?> get props => [];
}

class CarregarLotesEvent extends LotesEvent {
  final int balancoId;

  const CarregarLotesEvent({required this.balancoId});

  @override
  List<Object?> get props => [balancoId];
}

class CancelarLoteDaListaEvent extends LotesEvent {
  final int balancoId;
  final int loteId;
  final String motivo;

  const CancelarLoteDaListaEvent({
    required this.balancoId,
    required this.loteId,
    required this.motivo,
  });

  @override
  List<Object?> get props => [balancoId, loteId, motivo];
}
