import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import 'package:autenticacao/domain/models/terminal_do_usuario.dart';

class RecuperarTerminalDaSessao {
  final IUsuariosRepository _usuariosRepository;

  RecuperarTerminalDaSessao({required IUsuariosRepository usuariosRepository})
      : _usuariosRepository = usuariosRepository;

  Future<TerminalDoUsuario?> call() {
    return _usuariosRepository.getTerminalDaSessaoSalvo();
  }
}
