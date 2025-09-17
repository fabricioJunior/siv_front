import 'package:autenticacao/models.dart';

abstract class IPermissoesDoGrupoAcessoRemoteDataSource {
  Future<Iterable<Permissao>> getPermissoesDoGrupoDeAcesso({
    required int idGrupoDeAcesso,
  });

  Future<void> vincularPermissoesGrupoDeAcesso({
    required List<Permissao> permissoes,
    required int idGrupoDeAcesso,
  });

  Future<void> removerPermissoesGrupoDeAcesso({
    required List<Permissao> permissoes,
    required int idGrupoDeAcesso,
  });
}
