import 'package:json_annotation/json_annotation.dart';

part 'add_remove_balanco_lote_item_dto.g.dart';

@JsonSerializable()
class AddRemoveBalancoLoteItemDto {
  final int produtoId;
  final double quantidadeContada;

  AddRemoveBalancoLoteItemDto({
    required this.produtoId,
    required this.quantidadeContada,
  });

  factory AddRemoveBalancoLoteItemDto.fromJson(Map<String, dynamic> json) =>
      _$AddRemoveBalancoLoteItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AddRemoveBalancoLoteItemDtoToJson(this);
}
