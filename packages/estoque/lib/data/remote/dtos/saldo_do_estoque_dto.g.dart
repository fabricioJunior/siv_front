// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saldo_do_estoque_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaldoDoEstoqueDto _$SaldoDoEstoqueDtoFromJson(Map<String, dynamic> json) =>
    SaldoDoEstoqueDto(
      meta: MetaSaldoDoEstoqueDto.fromJson(
        json['meta'] as Map<String, dynamic>,
      ),
      items: (json['items'] as List<dynamic>)
          .map((e) => ProdutoDoEstoqueDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SaldoDoEstoqueDtoToJson(SaldoDoEstoqueDto instance) =>
    <String, dynamic>{
      'meta': instance.meta.toJson(),
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

MetaSaldoDoEstoqueDto _$MetaSaldoDoEstoqueDtoFromJson(
  Map<String, dynamic> json,
) => MetaSaldoDoEstoqueDto(
  totalItems: (json['totalItems'] as num).toInt(),
  itemCount: (json['itemCount'] as num).toInt(),
  itemsPerPage: (json['itemsPerPage'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
);

Map<String, dynamic> _$MetaSaldoDoEstoqueDtoToJson(
  MetaSaldoDoEstoqueDto instance,
) => <String, dynamic>{
  'totalItems': instance.totalItems,
  'itemCount': instance.itemCount,
  'itemsPerPage': instance.itemsPerPage,
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
};
