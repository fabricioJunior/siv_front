part of 'consultar_produto_bloc.dart';

abstract class ConsultarProdutoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConsultarProdutoBuscaAlterada extends ConsultarProdutoEvent {
  final String texto;
  ConsultarProdutoBuscaAlterada(this.texto);
  @override
  List<Object?> get props => [texto];
}

class ConsultarProdutoFiltrosAlterados extends ConsultarProdutoEvent {
  final List<Cor>? cores;
  final List<Tamanho>? tamanhos;
  final List<Estampa>? estampas;
  ConsultarProdutoFiltrosAlterados({this.cores, this.tamanhos, this.estampas});
  @override
  List<Object?> get props => [cores, tamanhos, estampas];
}

class ConsultarProdutoPesquisou extends ConsultarProdutoEvent {}

class ConsultarProdutoMaisCarregado extends ConsultarProdutoEvent {}

class ConsultarProdutoCodigoLido extends ConsultarProdutoEvent {
  final String codigo;
  ConsultarProdutoCodigoLido(this.codigo);
  @override
  List<Object?> get props => [codigo];
}

class ConsultarProdutoLeituraReiniciada extends ConsultarProdutoEvent {}

class ConsultarProdutoReferenciaSelecionada extends ConsultarProdutoEvent {
  final int referenciaId;
  ConsultarProdutoReferenciaSelecionada(this.referenciaId);
  @override
  List<Object?> get props => [referenciaId];
}

class ConsultarProdutoTabelaDePrecoAlterada extends ConsultarProdutoEvent {
  final List<SelectData> itens;
  ConsultarProdutoTabelaDePrecoAlterada(this.itens);
  @override
  List<Object?> get props => [itens];
}

class ConsultarProdutoLimpou extends ConsultarProdutoEvent {}
