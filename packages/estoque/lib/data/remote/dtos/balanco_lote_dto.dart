import 'package:json_annotation/json_annotation.dart';

part 'balanco_lote_dto.g.dart';

@JsonSerializable()
class BalancoLoteDto {
  @JsonKey(fromJson: _stringToInt)
  final int id;
  final int empresaId;
  @JsonKey(fromJson: _stringToInt)
  final int balancoId;
  final String lote;
  final String? observacao;
  final String situacao;
  final String? motivoCancelamento;
  final int operadorId;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  BalancoLoteDto({
    required this.id,
    required this.empresaId,
    required this.balancoId,
    required this.lote,
    this.observacao,
    required this.situacao,
    this.motivoCancelamento,
    required this.operadorId,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory BalancoLoteDto.fromJson(Map<String, dynamic> json) =>
      _$BalancoLoteDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BalancoLoteDtoToJson(this);

  static int _stringToInt(dynamic value) => int.parse(value.toString());
}
