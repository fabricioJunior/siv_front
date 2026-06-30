import 'package:estoque/data/remote/dtos/balanco_item_dto.dart';

class BalancoItensDto {
  final List<BalancoItemDto> itens;

  BalancoItensDto({required this.itens});

  BalancoItensDto.fromJson(Map<String, dynamic> json)
    : itens = (json['items'] as List)
          .map((item) => BalancoItemDto.fromJson(item))
          .toList();
}
