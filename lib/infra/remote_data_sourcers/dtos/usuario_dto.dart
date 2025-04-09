import 'package:autenticacao/models.dart';
import 'package:core/equals.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usuario_dto.g.dart';

@JsonSerializable()
class UsuarioDto with Usuario, EquatableMixin {
  @override
  final int id;

  @override
  @override
  @JsonKey(name: 'usuario')
  final String login;

  @override
  final String nome;

  @JsonKey(fromJson: _tipoUsuarioFromJson, toJson: _tipoUsuarioToJson)
  @override
  final TipoUsuario tipo;

  UsuarioDto({
    required this.id,
    required this.login,
    required this.nome,
    required this.tipo,
    this.senha,
  });

  factory UsuarioDto.fromJson(Map<String, dynamic> json) =>
      _$UsuarioDtoFromJson(json);

  @override
  @override
  @JsonKey(includeFromJson: true)
  List<Object?> get props => [
        id,
        login,
        nome,
      ];

  @override
  @JsonKey(includeFromJson: true)
  bool? get stringify => true;

  @override
  @JsonKey(includeFromJson: false)
  final String? senha;

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
