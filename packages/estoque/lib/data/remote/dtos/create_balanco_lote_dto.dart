import 'package:json_annotation/json_annotation.dart';

part 'create_balanco_lote_dto.g.dart';

@JsonSerializable()
class CreateBalancoLoteDto {
  final String lote;
  final String? observacao;

  CreateBalancoLoteDto({required this.lote, this.observacao});

  factory CreateBalancoLoteDto.fromJson(Map<String, dynamic> json) =>
      _$CreateBalancoLoteDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBalancoLoteDtoToJson(this);
}
