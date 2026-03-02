// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produtos_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProdutosDto _$ProdutosDtoFromJson(Map<String, dynamic> json) => ProdutosDto(
  items: (json['items'] as List<dynamic>)
      .map((e) => ProdutosDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);
