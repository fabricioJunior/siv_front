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
