// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pessoas_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PessoasDto _$PessoasDtoFromJson(Map<String, dynamic> json) => PessoasDto(
      meta: MetaDto.fromJson(json['meta'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((e) => PessoaDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PessoasDtoToJson(PessoasDto instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'items': instance.items,
    };
