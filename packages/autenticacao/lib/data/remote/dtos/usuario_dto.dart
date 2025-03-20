import 'package:autenticacao/domain/models/usuario.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usuario_dto.g.dart';

@JsonSerializable()
class UsuarioDto extends Usuario {
  @override
  @JsonKey(name: 'usuario')
  String get login => super.login;

  const UsuarioDto({
    required super.id,
    required super.criadoEm,
    required super.atualizadoEm,
    required super.login,
    required super.nome,
    required super.tipo,
  });

  Map<String, dynamic> toJson() => _$UsuarioDtoToJson(this);

  factory UsuarioDto.fromJson(Map<String, dynamic> json) =>
      _$UsuarioDtoFromJson(json);

  Usuario toModel() => Usuario(
        id: id,
        criadoEm: criadoEm,
        atualizadoEm: atualizadoEm,
        login: login,
        nome: nome,
        tipo: tipo,
      );
}

extension ToDto on Usuario {
  UsuarioDto toDto() => UsuarioDto(
        id: id,
        criadoEm: criadoEm,
        atualizadoEm: atualizadoEm,
        login: login,
        nome: nome,
        tipo: tipo,
      );
}
