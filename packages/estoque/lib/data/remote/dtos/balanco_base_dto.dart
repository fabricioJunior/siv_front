import 'package:json_annotation/json_annotation.dart';

part 'balanco_base_dto.g.dart';

@JsonSerializable()
class BalancoDto {
  @JsonKey(fromJson: _stringToInt)
  final int id;
  final int empresaId;
  final DateTime data;
  final String? observacao;
  final String situacao;
  final String? motivoCancelamento;
  final int operadorId;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  BalancoDto({
    required this.id,
    required this.empresaId,
    required this.data,
    this.observacao,
    required this.situacao,
    this.motivoCancelamento,
    required this.operadorId,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory BalancoDto.fromJson(Map<String, dynamic> json) =>
      _$BalancoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BalancoDtoToJson(this);

  static int _stringToInt(String value) => int.parse(value);
}
