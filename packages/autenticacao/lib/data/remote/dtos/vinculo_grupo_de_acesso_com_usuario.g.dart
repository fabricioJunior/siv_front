// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vinculo_grupo_de_acesso_com_usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VinculoGrupoDeAcessoComUsuarioDto _$VinculoGrupoDeAcessoComUsuarioDtoFromJson(
        Map<String, dynamic> json) =>
    VinculoGrupoDeAcessoComUsuarioDto(
      grupoId: (json['grupoId'] as num).toInt(),
      grupo: GrupoDeAcessoDto.fromJson(json['grupo'] as Map<String, dynamic>),
      empresaId: (json['empresaId'] as num).toInt(),
      usuarioId: (json['usuarioId'] as num).toInt(),
    );

Map<String, dynamic> _$VinculoGrupoDeAcessoComUsuarioDtoToJson(
        VinculoGrupoDeAcessoComUsuarioDto instance) =>
    <String, dynamic>{
      'grupoId': instance.grupoId,
      'empresaId': instance.empresaId,
      'usuarioId': instance.usuarioId,
      'grupo': instance.grupo,
    };
