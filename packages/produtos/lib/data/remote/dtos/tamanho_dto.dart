import 'package:produtos/models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tamanho_dto.g.dart';

@JsonSerializable()
class TamanhoDto implements Tamanho {
  @override
  final int? id;

  @override
  final bool inativo;

  @override
  final String nome;

  TamanhoDto({required this.id, required this.inativo, required this.nome});

  factory TamanhoDto.fromJson(Map<String, dynamic> json) =>
      _$TamanhoDtoFromJson(json);
}
