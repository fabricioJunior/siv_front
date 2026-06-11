// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balanco_lote_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BalancoLoteItemDto _$BalancoLoteItemDtoFromJson(Map<String, dynamic> json) =>
    BalancoLoteItemDto(
      empresaId: (json['empresaId'] as num).toInt(),
      balancoId: BalancoLoteItemDto._intFromString(json['balancoId'] as String),
      loteId: BalancoLoteItemDto._intFromString(json['loteId'] as String),
      sequencia: (json['sequencia'] as num).toInt(),
      produtoId: BalancoLoteItemDto._intFromString(json['produtoId'] as String),
      quantidadeContada: BalancoLoteItemDto._doubleFromString(
        json['quantidadeContada'] as String,
      ),
      operadorId: (json['operadorId'] as num).toInt(),
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );

Map<String, dynamic> _$BalancoLoteItemDtoToJson(BalancoLoteItemDto instance) =>
    <String, dynamic>{
      'empresaId': instance.empresaId,
      'balancoId': instance.balancoId,
      'loteId': instance.loteId,
      'sequencia': instance.sequencia,
      'produtoId': instance.produtoId,
      'quantidadeContada': instance.quantidadeContada,
      'operadorId': instance.operadorId,
      'criadoEm': instance.criadoEm.toIso8601String(),
      'atualizadoEm': instance.atualizadoEm.toIso8601String(),
    };
