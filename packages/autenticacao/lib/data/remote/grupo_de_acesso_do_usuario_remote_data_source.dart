import 'package:autenticacao/data/remote/dtos/grupo_de_acesso_dto.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_grupo_de_acesso_do_usuario_remote_data_source.dart';
import 'package:autenticacao/domain/models/grupo_de_acesso.dart';
import 'package:core/remote_data_sourcers.dart';

class GrupoDeAcessoDoUsuarioRemoteDataSource extends RemoteDataSourceBase
    implements IGrupoDeAcessoDoUsuarioRemoteDataSource {
  GrupoDeAcessoDoUsuarioRemoteDataSource({
    required super.informacoesParaRequest,
  });

  @override
  String get path => 'v1/usuario/{id}/grupo-acesso';

  @override
  Future<GrupoDeAcesso> recuperarGrupoDeAcessoDoUsuario(int idUsuario) async {
    var pathParamenters = {
      'id': idUsuario,
    };
    var response = await get(
      pathParameters: pathParamenters,
    );

    return GrupoDeAcessoDto.fromJson(response.body);
  }

  @override
  Future<void> vincularGrupoDeAcessoComUsuario(
    int idUser,
    int idGrupoDeAcesso,
  ) async {
    var pathParamenters = {
      'id': idUser,
    };
    await post(
      pathParameters: pathParamenters,
      body: {
        'grupoId': idGrupoDeAcesso,
      },
    );
  }
}
