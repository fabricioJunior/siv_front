// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balanco_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BalancoItemDto _$BalancoItemDtoFromJson(Map<String, dynamic> json) =>
    BalancoItemDto(
      empresaId: (json['empresaId'] as num).toInt(),
      balancoId: BalancoItemDto._stringToInt(json['balancoId']),
      sequencia: (json['sequencia'] as num).toInt(),
      produtoId: BalancoItemDto._stringToInt(json['produtoId']),
      quantidadeOriginal: BalancoItemDto._stringToDouble(
        json['quantidadeOriginal'],
      ),
      quantidadeContada: BalancoItemDto._stringToDouble(
        json['quantidadeContada'],
      ),
      operadorId: (json['operadorId'] as num).toInt(),
      produtoNome: json['produtoNome'] as String?,
      tamanho: json['tamanho'] as String?,
      cor: json['cor'] as String?,
      referencia: json['referencia'] as String?,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );

Map<String, dynamic> _$BalancoItemDtoToJson(BalancoItemDto instance) =>
    <String, dynamic>{
      'empresaId': instance.empresaId,
      'balancoId': instance.balancoId,
      'sequencia': instance.sequencia,
      'produtoId': instance.produtoId,
      'quantidadeOriginal': instance.quantidadeOriginal,
      'quantidadeContada': instance.quantidadeContada,
      'operadorId': instance.operadorId,
      'produtoNome': instance.produtoNome,
      'tamanho': instance.tamanho,
      'cor': instance.cor,
      'referencia': instance.referencia,
      'criadoEm': instance.criadoEm.toIso8601String(),
      'atualizadoEm': instance.atualizadoEm.toIso8601String(),
    };
