import 'package:autenticacao/models.dart';

abstract class IPermissoesDoUsuarioRemoteDataSource {
  Future<List<PermissaoDoUsuario>> getPermissoes(int idUsuario);
}
