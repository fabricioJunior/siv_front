part of 'lotes_bloc.dart';

sealed class LotesState extends Equatable {
  const LotesState();

  @override
  List<Object?> get props => [];
}

class LotesInitial extends LotesState {
  const LotesInitial();
}

class LotesLoading extends LotesState {
  const LotesLoading();
}

class LotesLoaded extends LotesState {
  final List<BalancoLote> lotes;

  const LotesLoaded({required this.lotes});

  @override
  List<Object?> get props => [lotes];
}

class LotesError extends LotesState {
  final String message;

  const LotesError({required this.message});

  @override
  List<Object?> get props => [message];
}
