part of 'balanco_itens_bloc.dart';

sealed class BalancoItensEvent extends Equatable {
  const BalancoItensEvent();

  @override
  List<Object?> get props => [];
}

class CarregarItensDoBalancoEvent extends BalancoItensEvent {
  final int balancoId;

  const CarregarItensDoBalancoEvent({required this.balancoId});

  @override
  List<Object?> get props => [balancoId];
}

class RemoverItemDoBalancoItensEvent extends BalancoItensEvent {
  final int balancoId;
  final int produtoId;

  const RemoverItemDoBalancoItensEvent({
    required this.balancoId,
    required this.produtoId,
  });

  @override
  List<Object?> get props => [balancoId, produtoId];
}
