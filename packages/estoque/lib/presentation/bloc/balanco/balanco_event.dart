part of 'balanco_bloc.dart';

sealed class BalancoEvent extends Equatable {
  const BalancoEvent();

  @override
  List<Object?> get props => [];
}

class CriarBalancoEvent extends BalancoEvent {
  final String? observacao;

  const CriarBalancoEvent({this.observacao});

  @override
  List<Object?> get props => [observacao];
}

class ListarBalancosEvent extends BalancoEvent {
  final String? situacao;
  final int page;
  final int limit;

  const ListarBalancosEvent({this.situacao, this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [situacao, page, limit];
}

class ObterBalancoEvent extends BalancoEvent {
  final int balancoId;

  const ObterBalancoEvent({required this.balancoId});

  @override
  List<Object?> get props => [balancoId];
}

class AtualizarBalancoEvent extends BalancoEvent {
  final int balancoId;
  final String? observacao;

  const AtualizarBalancoEvent({required this.balancoId, this.observacao});

  @override
  List<Object?> get props => [balancoId, observacao];
}

class EncerrarBalancoEvent extends BalancoEvent {
  final int balancoId;
  final String? observacao;

  const EncerrarBalancoEvent({required this.balancoId, this.observacao});

  @override
  List<Object?> get props => [balancoId, observacao];
}

class CancelarBalancoEvent extends BalancoEvent {
  final int balancoId;
  final String motivo;

  const CancelarBalancoEvent({required this.balancoId, required this.motivo});

  @override
  List<Object?> get props => [balancoId, motivo];
}

class ObterResumoBalancoEvent extends BalancoEvent {
  final int balancoId;

  const ObterResumoBalancoEvent({required this.balancoId});

  @override
  List<Object?> get props => [balancoId];
}

class AdicionarItemAoBalancoEvent extends BalancoEvent {
  final int balancoId;
  final int produtoId;

  const AdicionarItemAoBalancoEvent({
    required this.balancoId,
    required this.produtoId,
  });

  @override
  List<Object?> get props => [balancoId, produtoId];
}

class AdicionarMultiplosItensAoBalancoEvent extends BalancoEvent {
  final int balancoId;
  final List<int> referenciaIds;

  const AdicionarMultiplosItensAoBalancoEvent({
    required this.balancoId,
    required this.referenciaIds,
  });

  @override
  List<Object?> get props => [balancoId, referenciaIds];
}

class ListarItensDoBalancoEvent extends BalancoEvent {
  final int balancoId;

  const ListarItensDoBalancoEvent({required this.balancoId});

  @override
  List<Object?> get props => [balancoId];
}

class RemoverItemDoBalancoEvent extends BalancoEvent {
  final int balancoId;
  final int produtoId;

  const RemoverItemDoBalancoEvent({
    required this.balancoId,
    required this.produtoId,
  });

  @override
  List<Object?> get props => [balancoId, produtoId];
}
