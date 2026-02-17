import 'package:json_annotation/json_annotation.dart';
import 'package:produtos/models.dart';

part 'categoria_dto.g.dart';

@JsonSerializable()
class CategoriaDto implements Categoria {
  @override
  final int? id;

  @override
  final bool inativa;

  @override
  final String nome;

  CategoriaDto({required this.id, required this.inativa, required this.nome});

  factory CategoriaDto.fromJson(Map<String, dynamic> json) =>
      _$CategoriaDtoFromJson(json);
}
