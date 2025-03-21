import 'package:autenticacao/models.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/isar/isar_dto.dart';

part 'usuario_dto.g.dart';

@Collection(ignore: {'props'})
class UsuarioDto with Usuario implements IsarDto {
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

  @override
  final String? senha;

  const UsuarioDto({
    required this.id,
    required this.login,
    required this.nome,
    required this.tipo,
    required this.senha,
  });

  @override
  List<Object?> get props => [id, nome, tipo, login];

  @override
  bool? get stringify => true;
}
