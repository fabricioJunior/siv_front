part of 'balanco_lotes_bloc.dart';

sealed class BalancoLotesState extends Equatable {
  const BalancoLotesState();

  @override
  List<Object?> get props => [];
}

class BalancoLotesInitial extends BalancoLotesState {
  const BalancoLotesInitial();
}

class BalancoLotesLoading extends BalancoLotesState {
  const BalancoLotesLoading();
}

class BalancoLotesCarregados extends BalancoLotesState {
  final List<BalancoLote> lotes;

  const BalancoLotesCarregados({required this.lotes});

  @override
  List<Object?> get props => [lotes];
}

class BalancoLotesError extends BalancoLotesState {
  final String message;

  const BalancoLotesError({required this.message});

  @override
  List<Object?> get props => [message];
}
