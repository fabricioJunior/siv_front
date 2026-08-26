import 'package:autenticacao/domain/data/data_sourcers/local/i_permissoes_do_usuario_local_data_source.dart';
import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/permissao_do_usuario_hive_dto.dart';

class PermissoesDoUsuarioHiveDataSource extends HiveLocalDataSourceBase<
    PermissaoDoUsuarioHiveDto,
    PermissaoDoUsuario> implements IPermissoesDoUsuarioLocalDataSource<PermissaoDoUsuarioHiveDto> {
  PermissoesDoUsuarioHiveDataSource({required super.getBox});

  @override
  Future<List<Permissao>> getPermissoesPor({
    int? componenteId,
    String? nomeDoComponente,
    int? idGrupo,
    String? nomeGrupo,
  }) {
    throw UnimplementedError();
  }

  @override
  PermissaoDoUsuarioHiveDto toDto(PermissaoDoUsuario entity) {
    return PermissaoDoUsuarioHiveDto(
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
