import 'package:autenticacao/models.dart';

abstract class IPermissoesDoGrupoAcessoRemoteDataSource {
  Future<Iterable<Permissao>> getPermissoesDoGrupoDeAcesso({
    required int idGrupoDeAcesso,
  });

  Future<void> atualizarPermissoesGrupoDeAcesso({
    required List<Permissao> permissoes,
    required int idGrupoDeAcesso,
  });
}
