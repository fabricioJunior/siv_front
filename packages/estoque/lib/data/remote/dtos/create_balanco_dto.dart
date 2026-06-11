import 'package:json_annotation/json_annotation.dart';

part 'create_balanco_dto.g.dart';

@JsonSerializable()
class CreateBalancoDto {
  final String? observacao;

  CreateBalancoDto({this.observacao});

  factory CreateBalancoDto.fromJson(Map<String, dynamic> json) =>
      _$CreateBalancoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBalancoDtoToJson(this);
}
