part of 'etiquetas_bloc.dart';

abstract class EtiquetasEvent extends Equatable {
  const EtiquetasEvent();

  @override
  List<Object?> get props => [];
}

class EtiquetasIniciou extends EtiquetasEvent {
  const EtiquetasIniciou();
}

class EtiquetasCriarSolicitado extends EtiquetasEvent {
  final String nome;
  final double altura;
  final double largura;
  final EtiquetaDpi dpi;
  final List<EtiquetaElemento> elementos;
  final List<EtiquetaVia> vias;

  const EtiquetasCriarSolicitado({
    required this.nome,
    required this.altura,
    required this.largura,
    required this.dpi,
    required this.elementos,
    required this.vias,
  });

  @override
  List<Object?> get props => [nome, altura, largura, dpi, elementos, vias];
}

class EtiquetasExcluirSolicitado extends EtiquetasEvent {
  final int id;

  const EtiquetasExcluirSolicitado({required this.id});

  @override
  List<Object?> get props => [id];
}
