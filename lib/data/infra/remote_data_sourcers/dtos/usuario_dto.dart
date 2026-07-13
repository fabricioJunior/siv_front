import 'package:autenticacao/models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usuario_dto.g.dart';

@JsonSerializable(createToJson: false)
class UsuarioDto implements Usuario {
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

  @override
  @JsonKey(name: 'situacao', fromJson: _situacaoFromJson)
  final bool ativo;

  UsuarioDto({
    required this.id,
    required this.login,
    required this.nome,
    required this.tipo,
    this.senha,
    this.ativo = true,
  });

  factory UsuarioDto.fromJson(Map<String, dynamic> json) =>
      _$UsuarioDtoFromJson(json);

  @override
  @JsonKey(includeFromJson: true)
  List<Object?> get props => [id, login, nome, ativo];

  @override
  @JsonKey(includeFromJson: true)
  bool? get stringify => true;

  @override
  @JsonKey(includeFromJson: false)
  final String? senha;

  static bool _situacaoFromJson(String json) {
    switch (json) {
      case 'ativo':
        return true;
      case 'bloqueado':
        return false;
      case 'invativo':
        return false;
    }
    return true;
  }

  static String _tipoUsuarioToJson(TipoUsuario tipo) {
    switch (tipo) {
      case TipoUsuario.administrador:
        return 'administrador';
      case TipoUsuario.padrao:
        return 'padrao';
      case TipoUsuario.sysadmin:
        return 'sysadmin';
    }
  }

  static TipoUsuario _tipoUsuarioFromJson(String json) {
    switch (json) {
      case 'administrador':
        return TipoUsuario.administrador;
      case 'padrao':
        return TipoUsuario.padrao;
      case 'sysadmin':
        return TipoUsuario.sysadmin;
    }
    return TipoUsuario.padrao;
  }
}
