import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:json_annotation/json_annotation.dart';

part 'terminal_do_usuario_dto.g.dart';

@JsonSerializable(createToJson: false)
class TerminalDoUsuarioDto implements TerminalDoUsuario {
  @override
  final int id;

  @override
  final int idEmpresa;

  @override
  final String nome;

  TerminalDoUsuarioDto({
    required this.id,
    required this.idEmpresa,
    required this.nome,
  });

  factory TerminalDoUsuarioDto.fromJson(Map<String, dynamic> json) =>
      _$TerminalDoUsuarioDtoFromJson(json);

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Object?> get props => [id, idEmpresa, nome];

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool? get stringify => true;
}
