import 'package:json_annotation/json_annotation.dart';

part 'add_remove_balanco_item_dto.g.dart';

@JsonSerializable()
class AddRemoveBalancoItemDto {
  final int produtoId;

  AddRemoveBalancoItemDto({required this.produtoId});

  factory AddRemoveBalancoItemDto.fromJson(Map<String, dynamic> json) =>
      _$AddRemoveBalancoItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AddRemoveBalancoItemDtoToJson(this);
}
