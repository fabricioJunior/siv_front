import 'package:json_annotation/json_annotation.dart';

part 'update_balanco_lote_dto.g.dart';

@JsonSerializable()
class UpdateBalancoLoteDto {
  final String? lote;
  final String? observacao;

  UpdateBalancoLoteDto({this.lote, this.observacao});

  factory UpdateBalancoLoteDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateBalancoLoteDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateBalancoLoteDtoToJson(this);
}
