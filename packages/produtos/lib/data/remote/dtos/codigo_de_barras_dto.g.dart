// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'codigo_de_barras_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CodigoDeBarrasDto _$CodigoDeBarrasDtoFromJson(Map<String, dynamic> json) =>
    CodigoDeBarrasDto(
      tipo: $enumDecode(_$TipoCodigoDeBarrasEnumMap, json['tipo']),
      codigo: json['codigo'] as String,
    );

Map<String, dynamic> _$CodigoDeBarrasDtoToJson(CodigoDeBarrasDto instance) =>
    <String, dynamic>{
      'tipo': _$TipoCodigoDeBarrasEnumMap[instance.tipo]!,
      'codigo': instance.codigo,
    };

const _$TipoCodigoDeBarrasEnumMap = {
  TipoCodigoDeBarras.ean13: 'ean13',
  TipoCodigoDeBarras.rfid: 'rfid',
};
