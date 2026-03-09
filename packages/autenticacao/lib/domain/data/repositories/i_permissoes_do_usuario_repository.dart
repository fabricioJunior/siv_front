import 'package:autenticacao/domain/models/permissao_do_usuario.dart';

abstract class IPermissoesDoUsuarioRepository {
  Future<Iterable<PermissaoDoUsuario>> recuperaPermissoes();

  Future<void> sincronizarPermissoes(int idUsuario);
}
