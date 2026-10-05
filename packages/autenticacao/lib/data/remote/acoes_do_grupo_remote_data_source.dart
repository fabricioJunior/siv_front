import 'package:autenticacao/data/remote/dtos/acoes_do_grupo_dto.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_acoes_do_grupo_remote_data_source.dart';
import 'package:autenticacao/domain/models/acoes_do_grupo.dart';
import 'package:core/remote_data_sourcers.dart';

class AcoesDoGrupoRemoteDataSource extends RemoteDataSourceBase
    implements IAcoesDoGrupoRemoteDataSource {
  AcoesDoGrupoRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => 'v1/componentes-grupos/{id}/acoes';

  @override
  Future<AcoesDoGrupo> getAcoes({required int idGrupoDeAcesso}) async {
    final response = await get(
      pathParameters: {'id': idGrupoDeAcesso.toString()},
    );
    return acoesDoGrupoFromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<AcoesDoGrupo> aplicarAcoes({
    required int idGrupoDeAcesso,
    List<String> ativar = const [],
    List<String> desativar = const [],
  }) async {
    final response = await put(
      pathParameters: {'id': idGrupoDeAcesso.toString()},
      body: {'ativar': ativar, 'desativar': desativar},
    );
    return acoesDoGrupoFromJson(response.body as Map<String, dynamic>);
  }
}
