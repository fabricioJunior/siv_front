import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import 'package:autenticacao/domain/models/usuario.dart';

class RecuperarUsuario {
  final IUsuariosRepository usuariosRepository;

  RecuperarUsuario({required this.usuariosRepository});

  Future<Usuario?> call(int? id) async {
    return usuariosRepository.getUsuario(id: id);
  }
}
