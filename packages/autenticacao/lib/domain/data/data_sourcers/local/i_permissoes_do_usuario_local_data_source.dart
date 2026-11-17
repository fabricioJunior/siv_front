import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

abstract class IPermissoesDoUsuarioLocalDataSource<
    Dto extends PermissaoDoUsuario> implements ILocalDataSource<Dto> {
  Future<List<Permissao>> getPermissoesPor({
    int? componenteId,
    String? nomeDoComponente,
    int? idGrupo,
    String? nomeGrupo,
  });

  /// Remove as permissoes cujo componenteId nao esta em [componenteIds].
  Future<void> removerExceto(Set<String> componenteIds);
}
