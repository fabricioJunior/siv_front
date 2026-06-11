import 'package:json_annotation/json_annotation.dart';

part 'balanco_lote_item_dto.g.dart';

@JsonSerializable()
class BalancoLoteItemDto {
  final int empresaId;
  @JsonKey(fromJson: _intFromString)
  final int balancoId;
  @JsonKey(fromJson: _intFromString)
  final int loteId;
  final int sequencia;
  @JsonKey(fromJson: _intFromString)
  final int produtoId;
  @JsonKey(fromJson: _doubleFromString)
  final double quantidadeContada;
  final int operadorId;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  BalancoLoteItemDto({
    required this.empresaId,
    required this.balancoId,
    required this.loteId,
    required this.sequencia,
    required this.produtoId,
    required this.quantidadeContada,
    required this.operadorId,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory BalancoLoteItemDto.fromJson(Map<String, dynamic> json) =>
      _$BalancoLoteItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BalancoLoteItemDtoToJson(this);

  static int _intFromString(String value) => int.parse(value);

  static double _doubleFromString(String value) => double.parse(value);
}
