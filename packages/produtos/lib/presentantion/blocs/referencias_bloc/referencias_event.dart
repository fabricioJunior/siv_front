part of 'referencias_bloc.dart';

abstract class ReferenciasEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReferenciasIniciou extends ReferenciasEvent {
  final String? busca;
  final bool? inativo;
  final List<int> idsReferenciasSelecionadasIniciais;
  final List<Referencia> referenciasSelecionadasIniciais;

  ReferenciasIniciou({
    this.busca,
    this.inativo,
    this.idsReferenciasSelecionadasIniciais = const [],
    this.referenciasSelecionadasIniciais = const [],
  });

  @override
  List<Object?> get props => [
    busca,
    inativo,
    idsReferenciasSelecionadasIniciais,
    referenciasSelecionadasIniciais,
  ];
}
