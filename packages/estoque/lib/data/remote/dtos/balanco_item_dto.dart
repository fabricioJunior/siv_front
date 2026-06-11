import 'package:json_annotation/json_annotation.dart';

part 'balanco_item_dto.g.dart';

@JsonSerializable()
class BalancoItemDto {
  final int empresaId;
  @JsonKey(fromJson: _stringToInt)
  final int balancoId;
  final int sequencia;
  @JsonKey(fromJson: _stringToInt)
  final int produtoId;
  @JsonKey(fromJson: _stringToDouble)
  final double quantidadeOriginal;
  @JsonKey(fromJson: _stringToDouble)
  final double quantidadeContada;
  final int operadorId;
  final String? produtoNome;
  final String? tamanho;
  final String? cor;
  final String? referencia;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  BalancoItemDto({
    required this.empresaId,
    required this.balancoId,
    required this.sequencia,
    required this.produtoId,
    required this.quantidadeOriginal,
    required this.quantidadeContada,
    required this.operadorId,
    this.produtoNome,
    this.tamanho,
    this.cor,
    this.referencia,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory BalancoItemDto.fromJson(Map<String, dynamic> json) =>
      _$BalancoItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BalancoItemDtoToJson(this);

  static int _stringToInt(dynamic value) => int.parse(value.toString());
  static double _stringToDouble(dynamic value) =>
      double.parse(value.toString());
}
