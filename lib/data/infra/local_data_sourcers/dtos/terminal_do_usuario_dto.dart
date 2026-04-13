import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:core/isar_anotacoes.dart';

part 'terminal_do_usuario_dto.g.dart';

@Embedded(ignore: {'props', 'stringify'})
class TerminalDoUsuarioDto implements TerminalDoUsuario {
  @override
  final int id;

  @override
  final int idEmpresa;

  @override
  final String nome;

  TerminalDoUsuarioDto({this.id = 0, this.idEmpresa = 0, this.nome = ''});

  factory TerminalDoUsuarioDto.fromJson(Map<String, dynamic> json) =>
      TerminalDoUsuarioDto(
        id: json['id'] as int? ?? 0,
        idEmpresa: json['idEmpresa'] as int? ?? 0,
        nome: json['nome'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, idEmpresa, nome];

  @override
  bool? get stringify => true;
}

extension ToTerminalDoUsuarioDto on TerminalDoUsuario {
  TerminalDoUsuarioDto toDto() =>
      TerminalDoUsuarioDto(id: id, idEmpresa: idEmpresa, nome: nome);
}
