import 'package:autenticacao/domain/models/permissao.dart';

abstract class IPermissoesRemoteDataSource {
  Future<Iterable<Permissao>> getPermissoes();
}
