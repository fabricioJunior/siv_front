import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import 'package:autenticacao/domain/models/usuario.dart';

class RecuperarUsuarios {
  final IUsuariosRepository _usuariosRepository;

  RecuperarUsuarios({required IUsuariosRepository usuariosRepository})
      : _usuariosRepository = usuariosRepository;

  Future<Iterable<Usuario>> call() async {
    return _usuariosRepository.getUsuarios();
  }
}
