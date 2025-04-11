import 'package:autenticacao/data.dart';
import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';
import 'package:siv_front/infra/local_data_sourcers/dtos/permissao_dto.dart';

class PermissoesLocalDataSource
    extends IsarLocalDataSourceBase<PermissaoDto, Permissao>
    implements IPermissoesLocalDataSource<PermissaoDto> {
  PermissoesLocalDataSource({required super.getIsar});

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
  PermissaoDto toDto(Permissao entity) {
    return entity.toPermissaoDto();
  }
}
