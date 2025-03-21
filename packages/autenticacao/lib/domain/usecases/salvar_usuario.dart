import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';

class SalvarUsuario {
  final IUsuariosRepository usuariosRepository;

  SalvarUsuario({required this.usuariosRepository});

  // Future<void> call({
  //   required Usuario? usuario,
  //   String? nome,
  //   String? login,
  //   String? senha,
  //   String? tipo,
  // }) async {
  //   Usuario usuarioAtualizado = usuario?.copyWith();
  //   return usuariosRepository.salvarUsuario(usuario);
  // }
}
