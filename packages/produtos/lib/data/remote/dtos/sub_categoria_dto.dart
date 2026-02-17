import 'package:json_annotation/json_annotation.dart';
import 'package:produtos/models.dart';

part 'sub_categoria_dto.g.dart';

@JsonSerializable()
class SubCategoriaDto implements SubCategoria {
  @override
  final int? id;

  @override
  final int categoriaId;

  @override
  final bool inativa;

  @override
  final String nome;

  SubCategoriaDto({
    required this.id,
    required this.categoriaId,
    required this.inativa,
    required this.nome,
  });

  factory SubCategoriaDto.fromJson(Map<String, dynamic> json) =>
      _$SubCategoriaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubCategoriaDtoToJson(this);
}
