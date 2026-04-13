import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';

class DesvincularTerminalDoUsuario {
  final IUsuariosRepository _usuariosRepository;

  DesvincularTerminalDoUsuario({
    required IUsuariosRepository usuariosRepository,
  }) : _usuariosRepository = usuariosRepository;

  Future<void> call({
    required int usuarioId,
    required int terminalId,
  }) {
    return _usuariosRepository.desvincularTerminalDoUsuario(
      usuarioId: usuarioId,
      terminalId: terminalId,
    );
  }
}
