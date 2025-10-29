import 'package:autenticacao/domain/models/grupo_de_acesso.dart';
import 'package:autenticacao/domain/models/usuario.dart';

abstract class IUsuariosRepository {
  Future<Iterable<Usuario>> getUsuarios();

  Future<Usuario?> getUsuario({
    int? id,
  });

  Future<Usuario> getUsuarioDaSessao();

  Future<Usuario?> getUsuarioDaSessaoSalvo();

  Future<void> salvarUsuarioDaSessao(Usuario usuario);

  Future<void> apagarUsuarioDaSessao();

  Future<Usuario> salvarUsuario({
    int? id,
    String? login,
    required String nome,
    String? usuario,
    String? senha,
    required TipoUsuario tipo,
    required bool ativo,
  });
}
