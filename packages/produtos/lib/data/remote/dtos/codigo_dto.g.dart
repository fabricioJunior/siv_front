// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codigo_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodigoDto _$CodigoDtoFromJson(Map<String, dynamic> json) => CodigoDto(
  codigo: json['codigo'] as String,
  tipo: $enumDecode(_$TipoCodigoEnumMap, json['tipo'] ?? 'ean13'),
  produtoId: (json['produtoId'] as num).toInt(),
);

Map<String, dynamic> _$CodigoDtoToJson(CodigoDto instance) => <String, dynamic>{
  'codigo': instance.codigo,
  'tipo': _$TipoCodigoEnumMap[instance.tipo]!,
  'produtoId': instance.produtoId,
};

const _$TipoCodigoEnumMap = {
  TipoCodigo.ean13: 'ean13',
  TipoCodigo.rfid: 'rfid',
  TipoCodigo.ean8: 'ean8',
  TipoCodigo.upca: 'upca',
  TipoCodigo.upce: 'upce',
};
