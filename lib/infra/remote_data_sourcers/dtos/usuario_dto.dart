import 'package:autenticacao/models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'usuario_dto.g.dart';

@JsonSerializable()
class UsuarioDto implements Usuario {
  @override
  final DateTime atualizadoEm;

  @override
  final DateTime criadoEm;

  @override
  final int id;

  @override
  @override
  @JsonKey(name: 'usuario')
  final String login;

  @override
  final String nome;

  @override
  final String tipo;

  UsuarioDto({
    required this.atualizadoEm,
    required this.criadoEm,
    required this.id,
    required this.login,
    required this.nome,
    required this.tipo,
  });

  Map<String, dynamic> toJson() => _$UsuarioDtoToJson(this);

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
}
