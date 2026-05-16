import 'package:autenticacao/models.dart';
import 'package:core/isar_anotacoes.dart';

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

  @override
  final bool ativo;

  const UsuarioDto({
    required this.id,
    required this.login,
    required this.nome,
    required this.tipo,
    required this.senha,
    this.ativo = true,
  });

  @override
  List<Object?> get props => [id, nome, tipo, login, ativo];

  @override
  bool? get stringify => true;
}
