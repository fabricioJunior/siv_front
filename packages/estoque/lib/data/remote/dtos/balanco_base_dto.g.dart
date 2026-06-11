// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balanco_base_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BalancoDto _$BalancoDtoFromJson(Map<String, dynamic> json) => BalancoDto(
  id: BalancoDto._stringToInt(json['id'] as String),
  empresaId: (json['empresaId'] as num).toInt(),
  data: DateTime.parse(json['data'] as String),
  observacao: json['observacao'] as String?,
  situacao: json['situacao'] as String,
  motivoCancelamento: json['motivoCancelamento'] as String?,
  operadorId: (json['operadorId'] as num).toInt(),
  criadoEm: DateTime.parse(json['criadoEm'] as String),
  atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
);

Map<String, dynamic> _$BalancoDtoToJson(BalancoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresaId': instance.empresaId,
      'data': instance.data.toIso8601String(),
      'observacao': instance.observacao,
      'situacao': instance.situacao,
      'motivoCancelamento': instance.motivoCancelamento,
      'operadorId': instance.operadorId,
      'criadoEm': instance.criadoEm.toIso8601String(),
      'atualizadoEm': instance.atualizadoEm.toIso8601String(),
    };
