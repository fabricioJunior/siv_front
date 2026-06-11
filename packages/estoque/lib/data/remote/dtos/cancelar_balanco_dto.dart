import 'package:json_annotation/json_annotation.dart';

part 'cancelar_balanco_dto.g.dart';

@JsonSerializable()
class CancelarBalancoDto {
  final String motivo;

  CancelarBalancoDto({required this.motivo});

  factory CancelarBalancoDto.fromJson(Map<String, dynamic> json) =>
      _$CancelarBalancoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CancelarBalancoDtoToJson(this);
}
