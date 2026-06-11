part of 'balanco_itens_bloc.dart';

sealed class BalancoItensState extends Equatable {
  const BalancoItensState();

  @override
  List<Object?> get props => [];
}

class BalancoItensInitial extends BalancoItensState {
  const BalancoItensInitial();
}

class BalancoItensLoading extends BalancoItensState {
  const BalancoItensLoading();
}

class BalancoItensLoaded extends BalancoItensState {
  final List<BalancoItem> itens;

  const BalancoItensLoaded({required this.itens});

  @override
  List<Object?> get props => [itens];
}

class BalancoItensError extends BalancoItensState {
  final String message;

  const BalancoItensError({required this.message});

  @override
  List<Object?> get props => [message];
}
