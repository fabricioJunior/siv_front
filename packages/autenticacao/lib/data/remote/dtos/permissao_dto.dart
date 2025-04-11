import 'package:autenticacao/domain/models/permissao.dart';
import 'package:core/equals.dart';
import 'package:json_annotation/json_annotation.dart';

part 'permissao_dto.g.dart';

@JsonSerializable()
class PermissaoDto with Permissao, EquatableMixin {
  @override
  final int id;

  @override
  final String nome;

  @override
  final bool descontinuado;

  PermissaoDto({
    required this.id,
    required this.nome,
    required this.descontinuado,
  });

  factory PermissaoDto.fromJson(Map<String, dynamic> json) =>
      _$PermissaoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PermissaoDtoToJson(this);
}

extension PermissaoExtension on Permissao {
  PermissaoDto toPermissaoDto() {
    return PermissaoDto(
      id: id,
      nome: nome,
      descontinuado: descontinuado,
    );
  }
}
