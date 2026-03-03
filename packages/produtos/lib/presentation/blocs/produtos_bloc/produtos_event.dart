part of 'produtos_bloc.dart';

abstract class ProdutosEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProdutosIniciou extends ProdutosEvent {
  final String? idExterno;
  final int? referenciaId;

  ProdutosIniciou({this.idExterno, this.referenciaId});

  @override
  List<Object?> get props => [idExterno, referenciaId];
}

class ProdutosExcluiu extends ProdutosEvent {
  final int id;

  ProdutosExcluiu({required this.id});

  @override
  List<Object?> get props => [id];
}
