import 'package:json_annotation/json_annotation.dart';
import 'package:produtos/data/remote/dtos/produto_dto.dart';
part 'produtos_dto.g.dart';

@JsonSerializable(createToJson: false)
class ProdutosDto {
  final List<ProdutoDto> items;
  ProdutosDto({required this.items});

  factory ProdutosDto.fromJson(Map<String, dynamic> json) =>
      _$ProdutosDtoFromJson(json);
}
