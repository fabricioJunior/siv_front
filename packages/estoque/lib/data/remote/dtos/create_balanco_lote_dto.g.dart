// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_balanco_lote_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBalancoLoteDto _$CreateBalancoLoteDtoFromJson(
  Map<String, dynamic> json,
) => CreateBalancoLoteDto(
  lote: json['lote'] as String,
  observacao: json['observacao'] as String?,
);

Map<String, dynamic> _$CreateBalancoLoteDtoToJson(
  CreateBalancoLoteDto instance,
) => <String, dynamic>{
  'lote': instance.lote,
  'observacao': instance.observacao,
};
