import 'package:produtos/models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cor_dto.g.dart';

@JsonSerializable()
class CorDto implements Cor {
  @override
  final int? id;

  @override
  final bool? inativo;

  @override
  final String nome;

  CorDto({required this.id, required this.inativo, required this.nome});

  factory CorDto.fromJson(Map<String, dynamic> json) => _$CorDtoFromJson(json);

  @override
  List<Object?> get props => [id, inativo, nome];

  @override
  bool? get stringify => true;
}
