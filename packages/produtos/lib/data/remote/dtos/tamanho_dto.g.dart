// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tamanho_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TamanhoDto _$TamanhoDtoFromJson(Map<String, dynamic> json) => TamanhoDto(
  id: (json['id'] as num?)?.toInt(),
  inativo: json['inativo'] as bool,
  nome: json['nome'] as String,
);

Map<String, dynamic> _$TamanhoDtoToJson(TamanhoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inativo': instance.inativo,
      'nome': instance.nome,
    };
