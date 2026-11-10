import 'package:json_annotation/json_annotation.dart';
import 'package:produtos/models.dart';

import 'categoria_dto.dart';
import 'sub_categoria_dto.dart';

part 'referencia_dto.g.dart';

// A API guarda só a data (coluna DATE): manda AAAA-MM-DD, sem hora.
String? _soData(DateTime? data) => data?.toIso8601String().substring(0, 10);

ReferenciaStatusEntrada? _statusDeJson(Map<String, dynamic>? json) =>
    json == null ? null : ReferenciaStatusEntrada.fromJson(json);

@JsonSerializable(explicitToJson: true)
class ReferenciaDto implements Referencia {
  @override
  final int? id;

  @override
  final String nome;

  @override
  final DateTime? criadoEm;

  @override
  final DateTime? atualizadoEm;

  @override
  final String? idExterno;

  @override
  final String? unidadeMedida;

  @override
  final int? categoriaId;

  @override
  final int? subCategoriaId;

  @override
  final int? marcaId;

  @override
  final String? descricao;

  @override
  final String? composicao;

  @override
  final String? cuidados;

  @override
  final String? ncm;

  @override
  final int? pesoGramas;

  @override
  final int? fornecedorId;

  @override
  @JsonKey(includeToJson: false)
  final String? fornecedorNome;

  @override
  final bool? aguardandoReposicao;

  @override
  @JsonKey(toJson: _soData)
  final DateTime? previsaoChegada;

  @override
  final int? quantidadeEsperada;

  /// Calculado pela API: nunca volta no PUT.
  @override
  @JsonKey(includeToJson: false, fromJson: _statusDeJson)
  final ReferenciaStatusEntrada? status;

  @override
  @JsonKey(includeToJson: false)
  final CategoriaDto? categoria;

  @override
  @JsonKey(includeToJson: false)
  final SubCategoriaDto? subCategoria;

  ReferenciaDto({
    required this.id,
    required this.nome,
    this.criadoEm,
    this.atualizadoEm,
    this.idExterno,
    this.unidadeMedida,
    this.categoriaId,
    this.subCategoriaId,
    this.marcaId,
    this.descricao,
    this.composicao,
    this.cuidados,
    this.ncm,
    this.pesoGramas,
    this.fornecedorId,
    this.fornecedorNome,
    this.aguardandoReposicao,
    this.previsaoChegada,
    this.quantidadeEsperada,
    this.status,
    this.categoria,
    this.subCategoria,
  });

  factory ReferenciaDto.fromJson(Map<String, dynamic> json) =>
      _$ReferenciaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReferenciaDtoToJson(this);

  @override
  List<Object?> get props => [
    id,
    nome,
    criadoEm,
    atualizadoEm,
    idExterno,
    unidadeMedida,
    categoriaId,
    subCategoriaId,
    marcaId,
    descricao,
    composicao,
    cuidados,
    ncm,
    pesoGramas,
    fornecedorId,
    fornecedorNome,
    aguardandoReposicao,
    previsaoChegada,
    quantidadeEsperada,
    status,
    categoria,
    subCategoria,
  ];

  @override
  bool? get stringify => true;
}
