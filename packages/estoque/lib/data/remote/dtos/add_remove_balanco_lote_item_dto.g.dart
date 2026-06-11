// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_remove_balanco_lote_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddRemoveBalancoLoteItemDto _$AddRemoveBalancoLoteItemDtoFromJson(
  Map<String, dynamic> json,
) => AddRemoveBalancoLoteItemDto(
  produtoId: (json['produtoId'] as num).toInt(),
  quantidadeContada: (json['quantidadeContada'] as num).toDouble(),
);

Map<String, dynamic> _$AddRemoveBalancoLoteItemDtoToJson(
  AddRemoveBalancoLoteItemDto instance,
) => <String, dynamic>{
  'produtoId': instance.produtoId,
  'quantidadeContada': instance.quantidadeContada,
};
