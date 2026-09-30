part of 'referencia_bloc.dart';

abstract class ReferenciaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReferenciaIniciou extends ReferenciaEvent {
  final int idReferencia;

  ReferenciaIniciou({required this.idReferencia});

  @override
  List<Object?> get props => [idReferencia];
}

class ReferenciaAtualizou extends ReferenciaEvent {
  final int id;
  final String nome;
  final int categoriaId;
  final int? subCategoriaId;
  final int? marcaId;
  final String? idExterno;
  final String? unidadeMedida;
  final String? descricao;
  final String? composicao;
  final String? cuidados;
  final String? ncm;
  final int? pesoGramas;

  ReferenciaAtualizou({
    required this.id,
    required this.nome,
    required this.categoriaId,
    this.subCategoriaId,
    this.marcaId,
    this.idExterno,
    this.unidadeMedida,
    this.descricao,
    this.composicao,
    this.cuidados,
    this.ncm,
    this.pesoGramas,
  });

  @override
  List<Object?> get props => [
    id,
    nome,
    categoriaId,
    subCategoriaId,
    marcaId,
    idExterno,
    unidadeMedida,
    descricao,
    composicao,
    cuidados,
    ncm,
    pesoGramas,
  ];
}
