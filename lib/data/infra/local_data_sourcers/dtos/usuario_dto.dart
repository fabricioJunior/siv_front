import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:autenticacao/models.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:siv_front/data/infra/local_data_sourcers/dtos/terminal_do_usuario_dto.dart';

part 'usuario_dto.g.dart';

@Collection(ignore: {'props'})
class UsuarioDto implements Usuario, IsarDto {
  @override
  final int id;

  @override
  final String login;

  @override
  final String nome;

  @override
  @enumerated
  final TipoUsuario tipo;

  @override
  Id get dataBaseId => id;

  @override
  final String? senha;

  const UsuarioDto({
    required this.id,
    required this.login,
    required this.nome,
    required this.tipo,
    required this.senha,
    required this.terminaisDoUsuario,
  });

  @override
  List<Object?> get props => [id, nome, tipo, login, terminaisDoUsuario];

  @override
  bool? get stringify => true;

  @override
  final List<TerminalDoUsuarioDto> terminaisDoUsuario;
}
