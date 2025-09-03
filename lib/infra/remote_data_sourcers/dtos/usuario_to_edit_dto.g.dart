// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_to_edit_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsarioToEditDto _$UsarioToEditDtoFromJson(Map<String, dynamic> json) =>
    UsarioToEditDto(
      id: (json['id'] as num?)?.toInt(),
      login: json['usuario'] as String?,
      nome: json['nome'] as String,
      tipo: UsarioToEditDto._tipoUsuarioFromJson(json['tipo'] as String),
      situacao: json['situacao'] as String,
      senha: json['senha'] as String?,
    );

Map<String, dynamic> _$UsarioToEditDtoToJson(UsarioToEditDto instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      if (instance.login case final value?) 'usuario': value,
      'nome': instance.nome,
      'tipo': UsarioToEditDto._tipoUsuarioToJson(instance.tipo),
      if (instance.senha case final value?) 'senha': value,
      'situacao': instance.situacao,
    };
