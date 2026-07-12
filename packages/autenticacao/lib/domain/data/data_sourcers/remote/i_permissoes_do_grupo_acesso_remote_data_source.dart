import 'package:autenticacao/models.dart';

abstract class IPermissoesDoGrupoAcessoRemoteDataSource {
  Future<Iterable<Permissao>> getPermissoesDoGrupoDeAcesso({
    required int idGrupoDeAcesso,
  });

  /// Sincroniza de uma vez só a lista completa de permissões do grupo --
  /// usa o endpoint PUT /componentes-grupos/:id/itens, que faz upsert de
  /// tudo que está em [permissoes] e remove o resto (full sync no
  /// servidor). Substitui os antigos vincular/removerPermissoesGrupoDeAcesso,
  /// que faziam 1 requisição HTTP por permissão adicionada/removida --
  /// lento em grupos com muitas permissões.
  Future<void> sincronizarPermissoesGrupoDeAcesso({
    required List<Permissao> permissoes,
    required int idGrupoDeAcesso,
  });
}
