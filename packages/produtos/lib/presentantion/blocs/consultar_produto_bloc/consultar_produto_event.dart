part of 'consultar_produto_bloc.dart';

abstract class ConsultarProdutoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConsultarProdutoCodigoLido extends ConsultarProdutoEvent {
  final String codigo;

  ConsultarProdutoCodigoLido(this.codigo);

  @override
  List<Object?> get props => [codigo];
}

class ConsultarProdutoReferenciaSelecionada extends ConsultarProdutoEvent {
  final int referenciaId;

  ConsultarProdutoReferenciaSelecionada(this.referenciaId);

  @override
  List<Object?> get props => [referenciaId];
}

class ConsultarProdutoTabelaDePrecoAlterada extends ConsultarProdutoEvent {
  final int? tabelaDePrecoId;

  ConsultarProdutoTabelaDePrecoAlterada(this.tabelaDePrecoId);

  @override
  List<Object?> get props => [tabelaDePrecoId];
}

class ConsultarProdutoLimpou extends ConsultarProdutoEvent {}
