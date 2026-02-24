// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuracao_stmp_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfiguracaoSTMPDto _$ConfiguracaoSTMPDtoFromJson(Map<String, dynamic> json) =>
    ConfiguracaoSTMPDto(
      id: (json['id'] as num).toInt(),
      servidor: json['servidor'] as String,
      porta: (json['porta'] as num).toInt(),
      usuario: json['usuario'] as String,
      senha: json['senha'] as String,
      redefinirSenhaTemplate: RedefinirSenhaTemplateDto.fromJson(
          json['redefinirSenhaTemplate'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConfiguracaoSTMPDtoToJson(
        ConfiguracaoSTMPDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'servidor': instance.servidor,
      'porta': instance.porta,
      'usuario': instance.usuario,
      'senha': instance.senha,
      'redefinirSenhaTemplate': instance.redefinirSenhaTemplate,
    };

RedefinirSenhaTemplateDto _$RedefinirSenhaTemplateDtoFromJson(
        Map<String, dynamic> json) =>
    RedefinirSenhaTemplateDto(
      assunto: json['assunto'] as String,
      corpo: json['corpo'] as String,
    );

Map<String, dynamic> _$RedefinirSenhaTemplateDtoToJson(
        RedefinirSenhaTemplateDto instance) =>
    <String, dynamic>{
      'assunto': instance.assunto,
      'corpo': instance.corpo,
    };
