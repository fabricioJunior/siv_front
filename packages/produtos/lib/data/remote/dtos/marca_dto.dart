import 'package:json_annotation/json_annotation.dart';
import 'package:produtos/models.dart';

part 'marca_dto.g.dart';

@JsonSerializable()
class MarcaDto implements Marca {
  @override
  final int? id;

  @override
  final String nome;

  @override
  final bool inativa;

  MarcaDto({this.id, required this.nome, required this.inativa});

  factory MarcaDto.fromJson(Map<String, dynamic> json) =>
      _$MarcaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MarcaDtoToJson(this);

  @override
  List<Object?> get props => [id, nome, inativa];

  @override
  bool? get stringify => true;
}
