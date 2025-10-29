import 'package:autenticacao/domain/models/vinculo_grupo_de_acesso_e_usuario.dart';

abstract class IVinculoGrupoDeAcessoDoUsuarioRemoteDataSource {
  Future<VinculoGrupoDeAcessoEUsuario> vincularGrupoDeAcessoComUsuario(
    int idUser,
    int idGrupoDeAcesso,
    int idEmpresa,
  );

  Future<List<VinculoGrupoDeAcessoEUsuario>>
      recuperarGrupoDeAcessoDoUsuarioEIdEmpresa(
    int idUsuario,
  );
}
