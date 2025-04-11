import 'package:autenticacao/domain/models/permissao.dart';
import 'package:core/data_sourcers.dart';

abstract class IPermissoesLocalDataSource<Dto extends Permissao>
    implements ILocalDataSource<Dto> {
  Future<List<Permissao>> getPermissoesPor({
    int? componenteId,
    String? nomeDoComponente,
    int? idGrupo,
    String? nomeGrupo,
  });
}
