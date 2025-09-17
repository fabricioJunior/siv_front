import 'package:autenticacao/domain/models/permissao.dart';

import '../../models/grupo_de_acesso.dart';

abstract class IGruposDeAcessoRepository {
  Future<Iterable<GrupoDeAcesso>> getGruposDeAcesso();

  Future<GrupoDeAcesso?> getGrupoDeAcesso(int idGrupoDeAcesso);

  Future<GrupoDeAcesso> grupoDeAcessoDoUsuario(int idUsuario);

  Future<void> vincularGrupoDeAcessoComUsuario(
    int idUsuario,
    int idGrupoDeAcesso,
  );

  Future<GrupoDeAcesso> novoGrupoDeAcesso(String nome);

  Future<GrupoDeAcesso> salvarGrupoDeAcesso(
    GrupoDeAcesso grupoDeAcesso,
    List<Permissao> permissoesRemovidas,
    List<Permissao> permissoesAdicionadas,
  );

  Future<void> deleteGrupoDeAcesso(int idGrupoDeAcesso);
}
