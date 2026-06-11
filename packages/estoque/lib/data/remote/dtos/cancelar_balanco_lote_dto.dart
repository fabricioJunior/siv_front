import 'package:json_annotation/json_annotation.dart';

part 'cancelar_balanco_lote_dto.g.dart';

@JsonSerializable()
class CancelarBalancoLoteDto {
  final String motivo;

  CancelarBalancoLoteDto({required this.motivo});

  factory CancelarBalancoLoteDto.fromJson(Map<String, dynamic> json) =>
      _$CancelarBalancoLoteDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CancelarBalancoLoteDtoToJson(this);
}
