// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ponto_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PontoDto _$PontoDtoFromJson(Map<String, dynamic> json) => PontoDto(
      valor: _quantidadeFromJson(json['quantidade']),
      validade: _dateTimeFromJson(json['validaAte']),
      descricao: json['observacao'] as String,
      id: (json['id'] as num?)?.toInt(),
      dtCriacao: _nullableDateTimeFromJson(json['criadoEm']),
      cancelado: json['cancelado'] as bool? ?? false,
      motivoCancelamento: json['motivoCancelamento'] as String?,
      dtCancelamento: _nullableDateTimeFromJson(json['dtCancelamento']),
      tipo: _tipoDePontoFromJson(json['tipo']),
    );

Map<String, dynamic> _$PontoDtoToJson(PontoDto instance) => <String, dynamic>{
      'quantidade': instance.valor,
      'validaAte': _dateTimeToJson(instance.validade),
      'observacao': instance.descricao,
      'criadoEm': _dateTimeToJson(instance.dtCriacao),
      'cancelado': instance.cancelado,
      'motivoCancelamento': instance.motivoCancelamento,
      'dtCancelamento': _dateTimeToJson(instance.dtCancelamento),
      'tipo': _tipoDePontoToJson(instance.tipo),
    };
