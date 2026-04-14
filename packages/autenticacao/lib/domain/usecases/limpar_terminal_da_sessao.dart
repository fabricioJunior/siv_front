import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';

class LimparTerminalDaSessao {
  final IUsuariosRepository _usuariosRepository;

  LimparTerminalDaSessao({required IUsuariosRepository usuariosRepository})
      : _usuariosRepository = usuariosRepository;

  Future<void> call() {
    return _usuariosRepository.limparTerminalDaSessao();
  }
}
