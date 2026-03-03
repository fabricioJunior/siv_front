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
