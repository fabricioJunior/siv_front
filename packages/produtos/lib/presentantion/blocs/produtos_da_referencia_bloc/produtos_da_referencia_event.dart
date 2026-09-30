part of 'produtos_da_referencia_bloc.dart';

abstract class ProdutosDaReferenciaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProdutosDaReferenciaIniciou extends ProdutosDaReferenciaEvent {
  final int referenciaId;

  ProdutosDaReferenciaIniciou({required this.referenciaId});

  @override
  List<Object?> get props => [referenciaId];
}

class ProdutosDaReferenciaBuscouAlterou extends ProdutosDaReferenciaEvent {
  final String busca;

  ProdutosDaReferenciaBuscouAlterou({required this.busca});

  @override
  List<Object?> get props => [busca];
}

enum FiltroProdutosDaReferencia { todos, faltando }

class ProdutosDaReferenciaFiltroAlterou extends ProdutosDaReferenciaEvent {
  final FiltroProdutosDaReferencia filtro;

  ProdutosDaReferenciaFiltroAlterou({required this.filtro});

  @override
  List<Object?> get props => [filtro];
}

/// Cria uma célula, uma linha (cor x estampa) ou todos os faltantes de
/// uma vez -- em todos os casos é só a lista de combinações a criar.
class ProdutosDaReferenciaCriouCombinacoes extends ProdutosDaReferenciaEvent {
  final List<ComboDeGrade> combinacoes;

  ProdutosDaReferenciaCriouCombinacoes({required this.combinacoes});

  @override
  List<Object?> get props => [combinacoes];
}
