import 'package:autenticacao/data/remote/dtos/grupo_de_acesso_dto.dart';
import 'package:autenticacao/data/remote/dtos/permissao_dto.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_do_grupo_acesso_remote_data_source.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';
import 'package:autenticacao/domain/models/permissao.dart';
import 'package:core/remote_data_sourcers.dart';

class PermissoesDoGrupoAcessoRemoteDataSource extends RemoteDataSourceBase
    implements IPermissoesDoGrupoAcessoRemoteDataSource {
  PermissoesDoGrupoAcessoRemoteDataSource(
      {required super.informacoesParaRequest});

  @override
  String get path => 'v1/componentes-grupos/{id}/itens';

  @override
  Future<void> atualizarPermissoesGrupoDeAcesso({
    required List<Permissao> permissoes,
    required int idGrupoDeAcesso,
  }) async {
    var pathParameters = {
      'id': idGrupoDeAcesso.toString(),
    };
    for (var permissao in permissoes) {
      await post(
        body: {'componenteId': permissao.id},
        pathParameters: pathParameters,
      );
    }
  }

  @override
  Future<Iterable<Permissao>> getPermissoesDoGrupoDeAcesso({
    required int idGrupoDeAcesso,
  }) async {
    var queryParameters = {
      'id': idGrupoDeAcesso.toString(),
    };

    var response = await get(queryParameters: queryParameters);

    return (response.body as List).map((e) => PermissaoDto.fromJson(e));
  }
}
