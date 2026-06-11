import 'package:json_annotation/json_annotation.dart';

part 'encerrar_balanco_dto.g.dart';

@JsonSerializable()
class EncerrarBalancoDto {
  final String? observacao;

  EncerrarBalancoDto({this.observacao});

  factory EncerrarBalancoDto.fromJson(Map<String, dynamic> json) =>
      _$EncerrarBalancoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EncerrarBalancoDtoToJson(this);
}
