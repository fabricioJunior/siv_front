part of 'referencias_bloc.dart';

enum ReferenciasOrdenacao {
  nomeAsc,
  nomeDesc,
  criadoEmAsc,
  criadoEmDesc,
  atualizadoEmAsc,
  atualizadoEmDesc,
}

abstract class ReferenciasEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReferenciasIniciou extends ReferenciasEvent {
  final String? busca;
  final bool? inativo;
  final ReferenciasOrdenacao? ordenacao;
  final List<int> idsReferenciasSelecionadasIniciais;
  final List<Referencia> referenciasSelecionadasIniciais;

  ReferenciasIniciou({
    this.busca,
    this.inativo,
    this.ordenacao,
    this.idsReferenciasSelecionadasIniciais = const [],
    this.referenciasSelecionadasIniciais = const [],
  });

  @override
  List<Object?> get props => [
    busca,
    inativo,
    ordenacao,
    idsReferenciasSelecionadasIniciais,
    referenciasSelecionadasIniciais,
  ];
}
