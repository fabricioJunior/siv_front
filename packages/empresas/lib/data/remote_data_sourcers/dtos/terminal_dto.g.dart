// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TerminalDto _$TerminalDtoFromJson(Map<String, dynamic> json) => TerminalDto(
  criadoEm: json['criadoEm'] == null
      ? null
      : DateTime.parse(json['criadoEm'] as String),
  atualizadoEm: json['atualizadoEm'] == null
      ? null
      : DateTime.parse(json['atualizadoEm'] as String),
  id: (json['id'] as num?)?.toInt(),
  empresaId: (json['empresaId'] as num).toInt(),
  nome: json['nome'] as String,
  inativo: json['inativo'] as bool?,
);

Map<String, dynamic> _$TerminalDtoToJson(TerminalDto instance) =>
    <String, dynamic>{
      'criadoEm': ?instance.criadoEm?.toIso8601String(),
      'atualizadoEm': ?instance.atualizadoEm?.toIso8601String(),
      'id': ?instance.id,
      'empresaId': instance.empresaId,
      'nome': instance.nome,
      'inativo': ?instance.inativo,
    };
