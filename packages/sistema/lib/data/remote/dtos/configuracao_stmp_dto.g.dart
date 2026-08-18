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
      urlVerificacaoEmail: json['urlVerificacaoEmail'] as String?,
      verificacaoEmailTemplate: json['verificacaoEmailTemplate'] == null
          ? null
          : VerificacaoEmailTemplateDto.fromJson(
              json['verificacaoEmailTemplate'] as Map<String, dynamic>),
      pedidoConfirmadoTemplate: json['pedidoConfirmadoTemplate'] == null
          ? null
          : PedidoConfirmadoTemplateDto.fromJson(
              json['pedidoConfirmadoTemplate'] as Map<String, dynamic>),
      pedidoEmbaladoTemplate: json['pedidoEmbaladoTemplate'] == null
          ? null
          : PedidoEmbaladoTemplateDto.fromJson(
              json['pedidoEmbaladoTemplate'] as Map<String, dynamic>),
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
      'urlVerificacaoEmail': instance.urlVerificacaoEmail,
      'verificacaoEmailTemplate': instance.verificacaoEmailTemplate,
      'pedidoConfirmadoTemplate': instance.pedidoConfirmadoTemplate,
      'pedidoEmbaladoTemplate': instance.pedidoEmbaladoTemplate,
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

VerificacaoEmailTemplateDto _$VerificacaoEmailTemplateDtoFromJson(
        Map<String, dynamic> json) =>
    VerificacaoEmailTemplateDto(
      assunto: json['assunto'] as String,
      corpo: json['corpo'] as String,
    );

Map<String, dynamic> _$VerificacaoEmailTemplateDtoToJson(
        VerificacaoEmailTemplateDto instance) =>
    <String, dynamic>{
      'assunto': instance.assunto,
      'corpo': instance.corpo,
    };

PedidoConfirmadoTemplateDto _$PedidoConfirmadoTemplateDtoFromJson(
        Map<String, dynamic> json) =>
    PedidoConfirmadoTemplateDto(
      assunto: json['assunto'] as String,
      corpo: json['corpo'] as String,
    );

Map<String, dynamic> _$PedidoConfirmadoTemplateDtoToJson(
        PedidoConfirmadoTemplateDto instance) =>
    <String, dynamic>{
      'assunto': instance.assunto,
      'corpo': instance.corpo,
    };

PedidoEmbaladoTemplateDto _$PedidoEmbaladoTemplateDtoFromJson(
        Map<String, dynamic> json) =>
    PedidoEmbaladoTemplateDto(
      assunto: json['assunto'] as String,
      corpo: json['corpo'] as String,
    );

Map<String, dynamic> _$PedidoEmbaladoTemplateDtoToJson(
        PedidoEmbaladoTemplateDto instance) =>
    <String, dynamic>{
      'assunto': instance.assunto,
      'corpo': instance.corpo,
    };
