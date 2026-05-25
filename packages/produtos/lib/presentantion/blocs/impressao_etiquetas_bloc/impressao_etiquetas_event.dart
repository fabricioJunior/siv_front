part of 'impressao_etiquetas_bloc.dart';

abstract class ImpressaoEtiquetasEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ImpressaoEtiquetasIniciou extends ImpressaoEtiquetasEvent {}

class ImpressaoEtiquetasEtiquetaSelecionada extends ImpressaoEtiquetasEvent {
  final Etiqueta? etiqueta;

  ImpressaoEtiquetasEtiquetaSelecionada({required this.etiqueta});

  @override
  List<Object?> get props => [etiqueta];
}

class ImpressaoEtiquetasTabelaSelecionada extends ImpressaoEtiquetasEvent {
  final SelectData? tabela;

  ImpressaoEtiquetasTabelaSelecionada({required this.tabela});

  @override
  List<Object?> get props => [tabela];
}

class ImpressaoEtiquetasReferenciaSelecionada extends ImpressaoEtiquetasEvent {
  final Referencia? referencia;

  ImpressaoEtiquetasReferenciaSelecionada({required this.referencia});

  @override
  List<Object?> get props => [referencia];
}

class ImpressaoEtiquetasQuantidadeAlterada extends ImpressaoEtiquetasEvent {
  final int produtoId;
  final int quantidade;

  ImpressaoEtiquetasQuantidadeAlterada({
    required this.produtoId,
    required this.quantidade,
  });

  @override
  List<Object?> get props => [produtoId, quantidade];
}

class ImpressaoEtiquetasAdicionarSolicitado extends ImpressaoEtiquetasEvent {}

class ImpressaoEtiquetasImprimirSolicitado extends ImpressaoEtiquetasEvent {}

class ImpressaoEtiquetasPilhaLimpaSolicitada extends ImpressaoEtiquetasEvent {}

class ImpressaoEtiquetasPilhaQuantidadeAlterada extends ImpressaoEtiquetasEvent {
  final String referencia;
  final String cor;
  final String tamanho;
  final int quantidade;

  ImpressaoEtiquetasPilhaQuantidadeAlterada({
    required this.referencia,
    required this.cor,
    required this.tamanho,
    required this.quantidade,
  });

  @override
  List<Object?> get props => [referencia, cor, tamanho, quantidade];
}

class ImpressaoEtiquetasPilhaItemRemovido extends ImpressaoEtiquetasEvent {
  final String referencia;
  final String cor;
  final String tamanho;

  ImpressaoEtiquetasPilhaItemRemovido({
    required this.referencia,
    required this.cor,
    required this.tamanho,
  });

  @override
  List<Object?> get props => [referencia, cor, tamanho];
}

class ImpressaoEtiquetasPilhaOrdenacaoAlterada extends ImpressaoEtiquetasEvent {
  final PilhaImpressaoOrdenacao ordenacao;

  ImpressaoEtiquetasPilhaOrdenacaoAlterada({required this.ordenacao});

  @override
  List<Object?> get props => [ordenacao];
}
