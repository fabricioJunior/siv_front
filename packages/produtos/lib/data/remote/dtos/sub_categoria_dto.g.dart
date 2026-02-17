// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_categoria_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubCategoriaDto _$SubCategoriaDtoFromJson(Map<String, dynamic> json) =>
    SubCategoriaDto(
      id: (json['id'] as num?)?.toInt(),
      categoriaId: (json['categoriaId'] as num).toInt(),
      inativa: json['inativa'] as bool,
      nome: json['nome'] as String,
    );

Map<String, dynamic> _$SubCategoriaDtoToJson(SubCategoriaDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoriaId': instance.categoriaId,
      'inativa': instance.inativa,
      'nome': instance.nome,
    };
