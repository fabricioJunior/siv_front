import 'package:json_annotation/json_annotation.dart';
import 'package:pessoas/data/remote/dtos/meta_dto.dart';
import 'package:pessoas/data/remote/dtos/pessoa_dto.dart';

part 'pessoas_dto.g.dart';

@JsonSerializable()
class PessoasDto {
  final MetaDto meta;

  final List<PessoaDto> items;

  PessoasDto({
    required this.meta,
    required this.items,
  });

  factory PessoasDto.fromJson(Map<String, dynamic> json) =>
      _$PessoasDtoFromJson(json);
}
