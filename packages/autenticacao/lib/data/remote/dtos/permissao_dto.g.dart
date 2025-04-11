// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissao_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PermissaoDto _$PermissaoDtoFromJson(Map<String, dynamic> json) => PermissaoDto(
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String,
      descontinuado: json['descontinuado'] as bool,
    );

Map<String, dynamic> _$PermissaoDtoToJson(PermissaoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'descontinuado': instance.descontinuado,
    };
