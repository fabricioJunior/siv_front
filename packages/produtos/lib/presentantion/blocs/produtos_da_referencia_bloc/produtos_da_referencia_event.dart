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
