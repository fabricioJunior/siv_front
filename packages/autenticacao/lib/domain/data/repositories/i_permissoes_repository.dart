import 'package:autenticacao/domain/models/permissao.dart';

abstract class IPermissoesRepository {
  Future<void> syncPermissoesDoUsuario(int idUsuario);

  Future<Iterable<Permissao>> recuperarPermissoesPor({
    int? componenteId,
    String? nomeDoComponente,
    int? idGrupo,
    String? nomeGrupo,
  });

  Future<Iterable<Permissao>> recuperarPermissoesDoUsuario(int idUsuario);

  Future<Iterable<Permissao>> recuperarPermissoes();

  Future<Iterable<Permissao>> recuperarPermissoesDoGrupoDeAcesso(
    int idGrupoDeAcesso,
  );
}
