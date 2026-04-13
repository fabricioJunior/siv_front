import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';

class VincularTerminalAoUsuario {
  final IUsuariosRepository _usuariosRepository;

  VincularTerminalAoUsuario({
    required IUsuariosRepository usuariosRepository,
  }) : _usuariosRepository = usuariosRepository;

  Future<void> call({
    required int usuarioId,
    required int terminalId,
    required int idEmpresa,
  }) {
    return _usuariosRepository.vincularTerminalAoUsuario(
      usuarioId: usuarioId,
      terminalId: terminalId,
      idEmpresa: idEmpresa,
    );
  }
}
