import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import 'package:autenticacao/domain/models/usuario.dart';

class RecuperarUsuarioDaSessao {
  final IUsuariosRepository usuariosRepository;

  RecuperarUsuarioDaSessao({required this.usuariosRepository});

  Future<Usuario> call() async {
    var usuarioDaSessao = await usuariosRepository.getUsuarioDaSessaoSalvo();
    if (usuarioDaSessao == null) {
      usuarioDaSessao = await usuariosRepository.getUsuarioDaSessao();
      await usuariosRepository.salvarUsuarioDaSessao(usuarioDaSessao);
    }

    return usuariosRepository.getUsuarioDaSessao();
  }
}
