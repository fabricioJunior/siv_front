import 'package:json_annotation/json_annotation.dart';

part 'update_balanco_dto.g.dart';

@JsonSerializable()
class UpdateBalancoDto {
  final String? observacao;

  UpdateBalancoDto({this.observacao});

  factory UpdateBalancoDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateBalancoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateBalancoDtoToJson(this);
}
