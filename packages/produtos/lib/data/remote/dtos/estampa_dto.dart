import 'package:produtos/models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'estampa_dto.g.dart';

@JsonSerializable(createToJson: false)
class EstampaDto implements Estampa {
  @override
  final int? id;

  @override
  final bool inativo;

  @override
  final String nome;

  EstampaDto({required this.id, required this.inativo, required this.nome});

  factory EstampaDto.fromJson(Map<String, dynamic> json) =>
      _$EstampaDtoFromJson(json);

  @override
  List<Object?> get props => [id, inativo, nome];

  @override
  bool? get stringify => true;
}
