import 'package:json_annotation/json_annotation.dart';
import 'package:produtos/models.dart';

part 'referencia_midia_dto.g.dart';

@JsonSerializable()
class ReferenciaMidiaDto implements ReferenciaMidia {
  @override
  final int id;

  @override
  final String url;

  final bool isDefault;

  final bool isPublic;
  @override
  bool get ePrincipal => isDefault;

  @override
  bool get ePublica => isPublic;

  @override
  final int referenciaId;

  factory ReferenciaMidiaDto.fromJson(Map<String, dynamic> json) =>
      _$ReferenciaMidiaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReferenciaMidiaDtoToJson(this);

  ReferenciaMidiaDto({
    required this.id,
    required this.url,
    required this.isDefault,
    required this.isPublic,
    required this.referenciaId,
    required this.descricao,
  });

  @override
  @JsonKey(name: 'description')
  final String? descricao;
}

extension ToDto on ReferenciaMidia {
  ReferenciaMidiaDto toDto() {
    return ReferenciaMidiaDto(
      id: id,
      url: url,
      isDefault: ePrincipal,
      isPublic: ePublica,
      referenciaId: referenciaId,
      descricao: descricao,
    );
  }
}
