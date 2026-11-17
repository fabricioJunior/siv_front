part of 'etiquetas_promocao_bloc.dart';

abstract class EtiquetasPromocaoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EtiquetasPromocaoIniciou extends EtiquetasPromocaoEvent {}

class EtiquetasPromocaoVigenteAlterado extends EtiquetasPromocaoEvent {
  final bool apenasVigentes;
  EtiquetasPromocaoVigenteAlterado(this.apenasVigentes);

  @override
  List<Object?> get props => [apenasVigentes];
}

class EtiquetasPromocaoSelecionada extends EtiquetasPromocaoEvent {
  final PromocaoParaEtiqueta? promocao;
  EtiquetasPromocaoSelecionada(this.promocao);

  @override
  List<Object?> get props => [promocao];
}

class EtiquetasPromocaoTabelaSelecionada extends EtiquetasPromocaoEvent {
  final SelectData? tabela;
  EtiquetasPromocaoTabelaSelecionada(this.tabela);

  @override
  List<Object?> get props => [tabela?.id];
}

class EtiquetasPromocaoModeloSelecionado extends EtiquetasPromocaoEvent {
  final Etiqueta? etiqueta;
  EtiquetasPromocaoModeloSelecionado(this.etiqueta);

  @override
  List<Object?> get props => [etiqueta];
}

class EtiquetasPromocaoItemAlternado extends EtiquetasPromocaoEvent {
  final int produtoId;
  EtiquetasPromocaoItemAlternado(this.produtoId);

  @override
  List<Object?> get props => [produtoId];
}

class EtiquetasPromocaoTodosAlternado extends EtiquetasPromocaoEvent {
  final bool selecionar;
  EtiquetasPromocaoTodosAlternado(this.selecionar);

  @override
  List<Object?> get props => [selecionar];
}

class EtiquetasPromocaoImprimirSolicitado extends EtiquetasPromocaoEvent {}

/// A tela ja abriu o dialogo de impressao com a pilha; limpa para nao reabrir.
class EtiquetasPromocaoPilhaConsumida extends EtiquetasPromocaoEvent {}
