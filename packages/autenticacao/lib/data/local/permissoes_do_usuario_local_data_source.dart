import 'package:autenticacao/domain/data/data_sourcers/local/i_permissoes_do_usuario_local_data_source.dart';
import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/permissao_do_usuario_dto.dart';

class PermissoesDoUsuarioLocalDataSource
    extends IsarLocalDataSourceBase<PermissaoDoUsuarioDto, PermissaoDoUsuario>
    implements IPermissoesDoUsuarioLocalDataSource<PermissaoDoUsuarioDto> {
  PermissoesDoUsuarioLocalDataSource({required super.getIsar});

  @override
  Future<List<Permissao>> getPermissoesPor({
    int? componenteId,
    String? nomeDoComponente,
    int? idGrupo,
    String? nomeGrupo,
  }) {
    // TODO: implement getPermissoesPor
    throw UnimplementedError();
  }

  @override
  PermissaoDoUsuarioDto toDto(PermissaoDoUsuario entity) {
    return PermissaoDoUsuarioDto(
      id: entity.id,
      empresaId: entity.empresaId,
      grupoId: entity.grupoId,
      grupoNome: entity.grupoNome,
      componenteId: entity.componenteId,
      componenteNome: entity.componenteNome,
      descontinuado: entity.descontinuado,
    );
  }
}
