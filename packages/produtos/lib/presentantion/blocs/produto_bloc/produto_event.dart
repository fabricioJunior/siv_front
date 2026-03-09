part of 'produto_bloc.dart';

abstract class ProdutoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProdutoIniciou extends ProdutoEvent {
  final Produto? produto;

  ProdutoIniciou({this.produto});

  @override
  List<Object?> get props => [produto];
}

class ProdutoEditou extends ProdutoEvent {
  final int? referenciaId;
  final String? idExterno;
  final int? corId;
  final int? tamanhoId;

  ProdutoEditou({
    this.referenciaId,
    this.idExterno,
    this.corId,
    this.tamanhoId,
  });

  @override
  List<Object?> get props => [referenciaId, idExterno, corId, tamanhoId];
}

class ProdutoSalvou extends ProdutoEvent {}

class ProdutoCombinacaoSelecao extends Equatable {
  final int corId;
  final int tamanhoId;

  const ProdutoCombinacaoSelecao({
    required this.corId,
    required this.tamanhoId,
  });

  @override
  List<Object?> get props => [corId, tamanhoId];
}

class ProdutoSalvouCombinacoes extends ProdutoEvent {
  final int referenciaId;
  final List<ProdutoCombinacaoSelecao> combinacoes;

  ProdutoSalvouCombinacoes({
    required this.referenciaId,
    required this.combinacoes,
  });

  @override
  List<Object?> get props => [referenciaId, combinacoes];
}
