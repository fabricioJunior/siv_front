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

  Future<void> salvarUsuario(Usuario usuario);
}
