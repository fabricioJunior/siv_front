// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tabela_de_preco_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TabelaDePrecoDto _$TabelaDePrecoDtoFromJson(Map<String, dynamic> json) =>
    TabelaDePrecoDto(
      id: (json['id'] as num?)?.toInt(),
      nome: json['nome'] as String,
      terminador: (json['terminador'] as num?)?.toDouble(),
      inativa: json['inativa'] as bool,
    );

Map<String, dynamic> _$TabelaDePrecoDtoToJson(TabelaDePrecoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'terminador': instance.terminador,
      'inativa': instance.inativa,
    };
