import 'package:autenticacao/domain/models/grupo_de_acesso.dart';

abstract class IGruposDeAcessoRemoteDataSource {
  Future<Iterable<GrupoDeAcesso>> getGruposDeAcesso();

  Future<GrupoDeAcesso?> getGrupoDeAcesso(int idGrupoDeAcesso);

  Future<GrupoDeAcesso> postGrupoDeAcesso(String nome);

  Future<GrupoDeAcesso> putGrupoDeAcesso({
    required String nome,
    required int idGrupoDeAcesso,
  });
}
