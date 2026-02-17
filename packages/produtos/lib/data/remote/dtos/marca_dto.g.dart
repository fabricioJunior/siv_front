// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marca_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarcaDto _$MarcaDtoFromJson(Map<String, dynamic> json) => MarcaDto(
  id: (json['id'] as num?)?.toInt(),
  nome: json['nome'] as String,
  inativa: json['inativa'] as bool,
);

Map<String, dynamic> _$MarcaDtoToJson(MarcaDto instance) => <String, dynamic>{
  'id': instance.id,
  'nome': instance.nome,
  'inativa': instance.inativa,
};
