import 'package:autenticacao/domain/models/permissao.dart';

abstract class IPermissoesDoUsuarioRemoteDataSource {
  Future<List<Permissao>> getPermissoes(int idUsuario);
}
