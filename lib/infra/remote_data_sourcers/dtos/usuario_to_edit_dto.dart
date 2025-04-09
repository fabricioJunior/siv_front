import 'package:autenticacao/models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usuario_to_edit_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class UsarioToEditDto {
  final int? id;

  @JsonKey(name: 'usuario', includeToJson: true)
  final String? login;

  final String nome;

  @JsonKey(fromJson: _tipoUsuarioFromJson, toJson: _tipoUsuarioToJson)
  final TipoUsuario tipo;

  UsarioToEditDto({
    required this.id,
    required this.login,
    required this.nome,
    required this.tipo,
    required this.situacao,
    this.senha,
  });

  Map<String, dynamic> toJson() => _$UsarioToEditDtoToJson(this);

  factory UsarioToEditDto.fromJson(Map<String, dynamic> json) =>
      _$UsarioToEditDtoFromJson(json);

  final String? senha;

  final String situacao;

  static String _tipoUsuarioToJson(TipoUsuario tipo) {
    switch (tipo) {
      case TipoUsuario.administrador:
        return 'adminstrador';
      case TipoUsuario.padrao:
        return 'padrao';
      case TipoUsuario.sysadmin:
        return 'sysadmin';
    }
  }

  static TipoUsuario _tipoUsuarioFromJson(String json) {
    switch (json) {
      case 'adminstrador':
        return TipoUsuario.administrador;
      case 'padrao':
        return TipoUsuario.padrao;
      case 'sysadmin':
        return TipoUsuario.sysadmin;
    }
    return TipoUsuario.padrao;
  }
}
