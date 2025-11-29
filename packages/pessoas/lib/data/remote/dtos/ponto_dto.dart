// ...existing code...
import 'package:json_annotation/json_annotation.dart';
import 'package:pessoas/models.dart';

part 'ponto_dto.g.dart';

@JsonSerializable()
class PontoDto with Ponto {
  @override
  @JsonKey(
    name: 'quantidade',
    fromJson: _quantidadeFromJson,
  )
  final int valor;

  @override
  @JsonKey(
      name: 'validaAte', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime validade;

  @override
  @JsonKey(name: 'observacao')
  final String descricao;

  @override
  @JsonKey(
      name: 'criadoEm',
      fromJson: _nullableDateTimeFromJson,
      toJson: _dateTimeToJson)
  final DateTime? dtCriacao;

  @override
  final bool cancelado;

  @override
  final String? motivoCancelamento;

  @override
  @JsonKey(
      name: 'dtCancelamento',
      fromJson: _nullableDateTimeFromJson,
      toJson: _dateTimeToJson)
  final DateTime? dtCancelamento;

  const PontoDto({
    required this.valor,
    required this.validade,
    required this.descricao,
    int? id,
    this.dtCriacao,
    this.cancelado = false,
    this.motivoCancelamento,
    this.dtCancelamento,
  }) : _id = id;

  factory PontoDto.fromJson(Map<String, dynamic> json) =>
      _$PontoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PontoDtoToJson(this);

  @JsonKey(name: 'id')
  final int? _id;

  @override
  @JsonKey(includeToJson: false)
  int get id => _id ?? 0;
}

int _quantidadeFromJson(dynamic value) {
  if (value is String) {
    return double.parse(value).toInt();
  }
  if (value is num) {
    return value.toInt();
  }
  throw ArgumentError('Unexpected quantidade type: ${value.runtimeType}');
}

DateTime _dateTimeFromJson(dynamic value) {
  if (value == null) throw ArgumentError('Date value is null');
  if (value is int) {
    // assume epoch milliseconds
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String) {
    return DateTime.parse(value);
  }
  throw ArgumentError('Unexpected date format: ${value.runtimeType}');
}

DateTime? _nullableDateTimeFromJson(dynamic value) {
  if (value == null) return null;
  return _dateTimeFromJson(value);
}

String? _dateTimeToJson(DateTime? dt) => dt?.toIso8601String();
// ...existing code...
