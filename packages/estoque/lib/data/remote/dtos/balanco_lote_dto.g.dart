// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balanco_lote_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BalancoLoteDto _$BalancoLoteDtoFromJson(Map<String, dynamic> json) =>
    BalancoLoteDto(
      id: BalancoLoteDto._stringToInt(json['id']),
      empresaId: (json['empresaId'] as num).toInt(),
      balancoId: BalancoLoteDto._stringToInt(json['balancoId']),
      lote: json['lote'] as String,
      observacao: json['observacao'] as String?,
      situacao: json['situacao'] as String,
      motivoCancelamento: json['motivoCancelamento'] as String?,
      operadorId: (json['operadorId'] as num).toInt(),
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );

Map<String, dynamic> _$BalancoLoteDtoToJson(BalancoLoteDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'empresaId': instance.empresaId,
      'balancoId': instance.balancoId,
      'lote': instance.lote,
      'observacao': instance.observacao,
      'situacao': instance.situacao,
      'motivoCancelamento': instance.motivoCancelamento,
      'operadorId': instance.operadorId,
      'criadoEm': instance.criadoEm.toIso8601String(),
      'atualizadoEm': instance.atualizadoEm.toIso8601String(),
    };
