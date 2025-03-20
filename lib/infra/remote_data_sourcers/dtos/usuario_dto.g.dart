// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsuarioDto _$UsuarioDtoFromJson(Map<String, dynamic> json) => UsuarioDto(
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      id: (json['id'] as num).toInt(),
      login: json['usuario'] as String,
      nome: json['nome'] as String,
      tipo: json['tipo'] as String,
    );

Map<String, dynamic> _$UsuarioDtoToJson(UsuarioDto instance) =>
    <String, dynamic>{
      'atualizadoEm': instance.atualizadoEm.toIso8601String(),
      'criadoEm': instance.criadoEm.toIso8601String(),
      'id': instance.id,
      'usuario': instance.login,
      'nome': instance.nome,
      'tipo': instance.tipo,
    };
