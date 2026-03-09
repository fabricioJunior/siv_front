import 'package:autenticacao/models.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/isar/isar_dto.dart';

part 'permissao_do_usuario_dto.g.dart';

@Collection(ignore: {'props', 'stringify'})
class PermissaoDoUsuarioDto extends PermissaoDoUsuario
    implements IsarDto<PermissaoDoUsuario> {
  PermissaoDoUsuarioDto({
    required this.id,
    required this.empresaId,
    required this.grupoId,
    required this.grupoNome,
    required this.componenteId,
    required this.componenteNome,
    required this.descontinuado,
  });

  @override
  final int id;

  @override
  final int empresaId;

  @override
  final int grupoId;

  @override
  final String grupoNome;

  @override
  final String componenteId;

  @override
  final String componenteNome;

  @override
  final int descontinuado;

  @override
  Id get dataBaseId => fastHash(componenteId);
}
