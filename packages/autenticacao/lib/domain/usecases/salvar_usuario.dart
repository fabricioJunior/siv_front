import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import '../models/usuario.dart';

class SalvarUsuario {
  final IUsuariosRepository usuariosRepository;

  SalvarUsuario({
    required this.usuariosRepository,
  });

  Future<Usuario> call({
    required Usuario? usuario,
    int? idUsuario,
    required String nome,
    String? login,
    String? senha,
    required TipoUsuario tipo,
  }) async {
    return await usuariosRepository.salvarUsuario(
      id: idUsuario ?? usuario?.id,
      login: login,
      senha: senha,
      tipo: tipo,
      nome: nome,
      ativo: true,
      usuario: login,
    );
  }
}
