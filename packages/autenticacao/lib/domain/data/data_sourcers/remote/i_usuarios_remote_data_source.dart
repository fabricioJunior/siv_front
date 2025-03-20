import 'package:autenticacao/domain/models/usuario.dart';

abstract class IUsuariosRemoteDataSource {
  Future<Iterable<Usuario>> getUsuarios();

  Future<Usuario?> getUsuario({int? id});

  Future<void> postUsuario(Usuario usuario);
}
