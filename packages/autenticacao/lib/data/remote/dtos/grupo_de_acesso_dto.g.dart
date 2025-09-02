// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grupo_de_acesso_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrupoDeAcessoDto _$GrupoDeAcessoDtoFromJson(Map<String, dynamic> json) =>
    GrupoDeAcessoDto(
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String,
      permissoes: (json['itens'] as List<dynamic>)
          .map((e) => PermissaoDto.fromJson(e as Map<String, dynamic>)),
    );

Map<String, dynamic> _$GrupoDeAcessoDtoToJson(GrupoDeAcessoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
    };

_Item _$ItemFromJson(Map<String, dynamic> json) => _Item(
      permissoes: (json['permissoes'] as List<dynamic>?)
              ?.map((e) => PermissaoDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
