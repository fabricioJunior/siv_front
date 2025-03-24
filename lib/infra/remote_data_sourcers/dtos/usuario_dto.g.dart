// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsuarioDto _$UsuarioDtoFromJson(Map<String, dynamic> json) => UsuarioDto(
      id: (json['id'] as num).toInt(),
      login: json['usuario'] as String,
      nome: json['nome'] as String,
      tipo: UsuarioDto._tipoUsuarioFromJson(json['tipo'] as String),
    );

Map<String, dynamic> _$UsuarioDtoToJson(UsuarioDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'usuario': instance.login,
      'nome': instance.nome,
      'tipo': UsuarioDto._tipoUsuarioToJson(instance.tipo),
    };
