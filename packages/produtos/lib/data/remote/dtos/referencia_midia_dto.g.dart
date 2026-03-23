// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referencia_midia_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferenciaMidiaDto _$ReferenciaMidiaDtoFromJson(Map<String, dynamic> json) =>
    ReferenciaMidiaDto(
      id: (json['id'] as num).toInt(),
      url: json['url'] as String,
      isDefault: json['isDefault'] as bool,
      isPublic: json['isPublic'] as bool,
      referenciaId: (json['referenciaId'] as num).toInt(),
      descricao: json['description'] as String?,
    );

Map<String, dynamic> _$ReferenciaMidiaDtoToJson(ReferenciaMidiaDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'isDefault': instance.isDefault,
      'isPublic': instance.isPublic,
      'referenciaId': instance.referenciaId,
      'description': instance.descricao,
    };
