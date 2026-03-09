import 'package:autenticacao/models.dart';

abstract class IPermissoesRepository {
  Future<void> syncPermissoesDoUsuario(int idUsuario);

  Future<Iterable<Permissao>> recuperarPermissoesPor({
    int? componenteId,
    String? nomeDoComponente,
    int? idGrupo,
    String? nomeGrupo,
  });

  Future<Iterable<PermissaoDoUsuario>> recuperarPermissoesDoUsuario(
      int idUsuario);

  Future<Iterable<Permissao>> recuperarPermissoes();

  Future<Iterable<Permissao>> recuperarPermissoesDoGrupoDeAcesso(
    int idGrupoDeAcesso,
  );
}
