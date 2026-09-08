import 'package:json_annotation/json_annotation.dart';
import 'package:produtos/models.dart';

part 'categoria_dto.g.dart';

@JsonSerializable(createToJson: false)
class CategoriaDto implements Categoria {
  @override
  final int? id;

  @override
  final bool inativa;

  @override
  final String nome;

  @override
  final String? ncm;

  @override
  final String? descricao;

  @override
  final String? icone;

  @override
  final int? pesoGramas;

  CategoriaDto({
    required this.id,
    required this.inativa,
    required this.nome,
    this.ncm,
    this.descricao,
    this.icone,
    this.pesoGramas,
  });

  factory CategoriaDto.fromJson(Map<String, dynamic> json) =>
      _$CategoriaDtoFromJson(json);
}
