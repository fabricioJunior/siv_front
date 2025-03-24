import 'package:autenticacao/domain/models/usuario.dart';

abstract class IUsuariosRemoteDataSource {
  Future<Iterable<Usuario>> getUsuarios();

  Future<Usuario?> getUsuario({int? id});

  Future<Usuario> postUsuario({
    int? id,
    String? login,
    required String nome,
    required String usuario,
    String? senha,
    required TipoUsuario tipo,
    required bool ativo,
  });

  Future<Usuario> putUsuario({
    required int id,
    String? login,
    required String nome,
    String? senha,
    required TipoUsuario tipo,
    required bool ativo,
  });
}
