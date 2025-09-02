import '../../models/grupo_de_acesso.dart';

abstract class IGruposDeAcessoRepository {
  Future<Iterable<GrupoDeAcesso>> getGruposDeAcesso();

  Future<GrupoDeAcesso?> getGrupoDeAcesso(int idGrupoDeAcesso);

  Future<GrupoDeAcesso> grupoDeAcessoDoUsuario(int idUsuario);

  Future<GrupoDeAcesso> novoGrupoDeAcesso(String nome);

  Future<GrupoDeAcesso> salvarGrupoDeAcesso(GrupoDeAcesso grupoDeAcesso);
}
