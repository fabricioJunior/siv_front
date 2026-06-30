part of 'balanco_itens_bloc.dart';

sealed class BalancoItensEvent extends Equatable {
  const BalancoItensEvent();

  @override
  List<Object?> get props => [];
}

class CarregarItensDoBalancoEvent extends BalancoItensEvent {
  final int balancoId;
  final int page;
  final int limit;
  final bool? comDivergencia;
  final List<String>? referencias;
  final List<String>? ordenacao;

  const CarregarItensDoBalancoEvent({
    required this.balancoId,
    this.page = 1,
    this.limit = 25,
    this.comDivergencia,
    this.referencias,
    this.ordenacao,
  });

  @override
  List<Object?> get props => [balancoId, page, limit, comDivergencia, referencias, ordenacao];
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

class CalcularItensDoBalancoEvent extends BalancoItensEvent {
  final int balancoId;

  const CalcularItensDoBalancoEvent({required this.balancoId});

  @override
  List<Object?> get props => [balancoId];
}
