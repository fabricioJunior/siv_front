import 'package:json_annotation/json_annotation.dart';
import 'package:produtos/models.dart';

import 'categoria_dto.dart';
import 'sub_categoria_dto.dart';

part 'referencia_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ReferenciaDto implements Referencia {
  @override
  final int? id;

  @override
  final String nome;

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
  @JsonKey(includeToJson: false)
  final CategoriaDto? categoria;

  @override
  @JsonKey(includeToJson: false)
  final SubCategoriaDto? subCategoria;

  ReferenciaDto({
    required this.id,
    required this.nome,
    this.idExterno,
    this.unidadeMedida,
    this.categoriaId,
    this.subCategoriaId,
    this.marcaId,
    this.descricao,
    this.composicao,
    this.cuidados,
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
    idExterno,
    unidadeMedida,
    categoriaId,
    subCategoriaId,
    marcaId,
    descricao,
    composicao,
    cuidados,
    categoria,
    subCategoria,
  ];

  @override
  bool? get stringify => true;
}
