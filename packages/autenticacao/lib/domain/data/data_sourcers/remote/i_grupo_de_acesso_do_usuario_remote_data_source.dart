import 'package:autenticacao/domain/models/grupo_de_acesso.dart';

abstract class IGrupoDeAcessoDoUsuarioRemoteDataSource {
  Future<void> vincularGrupoDeAcessoComUsuario(
    int idUser,
    int idGrupoDeAcesso,
  );

  Future<GrupoDeAcesso> recuperarGrupoDeAcessoDoUsuario(int idUser);
}
