import 'package:autenticacao/data/remote/dtos/vinculo_grupo_de_acesso_com_usuario.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_grupo_de_acesso_do_usuario_remote_data_source.dart';
import 'package:autenticacao/domain/models/vinculo_grupo_de_acesso_e_usuario.dart';
import 'package:core/remote_data_sourcers.dart';

class VinculorGrupoDeAcessoDoUsuarioRemoteDataSource
    extends RemoteDataSourceBase
    implements IVinculoGrupoDeAcessoDoUsuarioRemoteDataSource {
  VinculorGrupoDeAcessoDoUsuarioRemoteDataSource({
    required super.informacoesParaRequest,
  });

  @override
  String get path => 'v1/usuario/{id}/grupo-acesso';

  @override
  Future<List<VinculoGrupoDeAcessoComUsuarioDto>>
      recuperarGrupoDeAcessoDoUsuarioEIdEmpresa(
    int idUsuario,
  ) async {
    var pathParamenters = {
      'id': idUsuario,
    };
    var response = await get(
      pathParameters: pathParamenters,
    );
    var dto = (response.body as List<dynamic>)
        .map((e) => VinculoGrupoDeAcessoComUsuarioDto.fromJson(
            e as Map<String, dynamic>))
        .toList();
    return dto;
  }

  @override
  Future<VinculoGrupoDeAcessoEUsuario> vincularGrupoDeAcessoComUsuario(
    int idUser,
    int idGrupoDeAcesso,
    int idEmpresa,
  ) async {
    var pathParamenters = {
      'id': idUser,
    };
    var result = await post(
      pathParameters: pathParamenters,
      body: {
        'grupoId': idGrupoDeAcesso,
        'empresaId': idEmpresa,
      },
    );

    return VinculoGrupoDeAcessoComUsuarioDto.fromJson(
        result.body as Map<String, dynamic>);
  }
}
