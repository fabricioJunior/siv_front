// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CorDto _$CorDtoFromJson(Map<String, dynamic> json) => CorDto(
  id: (json['id'] as num?)?.toInt(),
  inativo: json['inativo'] as bool?,
  nome: json['nome'] as String,
);

Map<String, dynamic> _$CorDtoToJson(CorDto instance) => <String, dynamic>{
  'id': instance.id,
  'inativo': instance.inativo,
  'nome': instance.nome,
};
