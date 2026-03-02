import 'package:json_annotation/json_annotation.dart';
part 'produtos_dto.g.dart';

@JsonSerializable(createToJson: false)
class ProdutosDto {
  final List<ProdutosDto> items;
  ProdutosDto({required this.items});

  factory ProdutosDto.fromJson(Map<String, dynamic> json) =>
      _$ProdutosDtoFromJson(json);
}
