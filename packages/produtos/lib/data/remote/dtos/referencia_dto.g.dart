// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referencia_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferenciaDto _$ReferenciaDtoFromJson(Map<String, dynamic> json) =>
    ReferenciaDto(
      id: (json['id'] as num?)?.toInt(),
      nome: json['nome'] as String,
      criadoEm: json['criadoEm'] == null
          ? null
          : DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: (json['atualizadoEm'] ?? json['atualizadorEm']) == null
          ? null
          : DateTime.parse(
              (json['atualizadoEm'] ?? json['atualizadorEm']) as String,
            ),
      idExterno: json['idExterno'] as String?,
      unidadeMedida: json['unidadeMedida'] as String?,
      categoriaId: (json['categoriaId'] as num?)?.toInt(),
      subCategoriaId: (json['subCategoriaId'] as num?)?.toInt(),
      marcaId: (json['marcaId'] as num?)?.toInt(),
      descricao: json['descricao'] as String?,
      composicao: json['composicao'] as String?,
      cuidados: json['cuidados'] as String?,
      categoria: json['categoria'] == null
          ? null
          : CategoriaDto.fromJson(json['categoria'] as Map<String, dynamic>),
      subCategoria: json['subCategoria'] == null
          ? null
          : SubCategoriaDto.fromJson(
              json['subCategoria'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ReferenciaDtoToJson(ReferenciaDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'criadoEm': instance.criadoEm?.toIso8601String(),
      'atualizadoEm': instance.atualizadoEm?.toIso8601String(),
      'idExterno': instance.idExterno,
      'unidadeMedida': instance.unidadeMedida,
      'categoriaId': instance.categoriaId,
      'subCategoriaId': instance.subCategoriaId,
      'marcaId': instance.marcaId,
      'descricao': instance.descricao,
      'composicao': instance.composicao,
      'cuidados': instance.cuidados,
    };
