import 'package:autenticacao/data/remote/dtos/permissao_dto.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_do_grupo_acesso_remote_data_source.dart';
import 'package:autenticacao/domain/models/permissao.dart';
import 'package:core/remote_data_sourcers.dart';

class PermissoesDoGrupoAcessoRemoteDataSource extends RemoteDataSourceBase
    implements IPermissoesDoGrupoAcessoRemoteDataSource {
  PermissoesDoGrupoAcessoRemoteDataSource(
      {required super.informacoesParaRequest});

  @override
  String get path => 'v1/componentes-grupos/{id}/itens/{componente}';

  @override
  Future<void> sincronizarPermissoesGrupoDeAcesso({
    required List<Permissao> permissoes,
    required int idGrupoDeAcesso,
  }) async {
    var pathParameters = {
      'id': idGrupoDeAcesso.toString(),
    };
    // 1 requisição só -- PUT /componentes-grupos/:id/itens faz upsert de
    // toda a lista e remove o que não estiver nela (full sync), em vez de
    // 1 POST por permissão adicionada + 1 DELETE por permissão removida.
    await put(
      body: permissoes
          .map((permissao) => {'componenteId': permissao.id})
          .toList(),
      pathParameters: pathParameters,
    );
  }

  @override
  Future<Iterable<Permissao>> getPermissoesDoGrupoDeAcesso({
    required int idGrupoDeAcesso,
  }) async {
    var queryParameters = {
      'id': idGrupoDeAcesso.toString(),
    };

    var response = await get(queryParameters: queryParameters);

    return (response.body as List)
        .map((e) => PermissaoDto.fromJson(e))
        .toList();
  }
}
