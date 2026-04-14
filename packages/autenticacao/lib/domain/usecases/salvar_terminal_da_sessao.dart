import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import 'package:autenticacao/domain/models/terminal_do_usuario.dart';

class SalvarTerminalDaSessao {
  final IUsuariosRepository _usuariosRepository;

  SalvarTerminalDaSessao({required IUsuariosRepository usuariosRepository})
      : _usuariosRepository = usuariosRepository;

  Future<void> call(TerminalDoUsuario terminal) {
    return _usuariosRepository.salvarTerminalDaSessao(terminal);
  }
}
