import 'package:autenticacao/models.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/isar/isar_dto.dart';

part 'usuario_dto.g.dart';

@Collection(ignore: {'props'})
class UsuarioDto implements IsarDto, Usuario {
  @override
  final DateTime atualizadoEm;

  @override
  final DateTime criadoEm;

  @override
  final int id;

  @override
  final String login;

  @override
  final String nome;

  @override
  final String tipo;

  @override
  Id get dataBaseId => id;

  const UsuarioDto(
      {required this.atualizadoEm,
      required this.criadoEm,
      required this.id,
      required this.login,
      required this.nome,
      required this.tipo});

  @override
  List<Object?> get props => [id, nome, tipo, criadoEm, atualizadoEm, login];

  @override
  bool? get stringify => true;
}
