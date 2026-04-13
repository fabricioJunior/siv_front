import 'package:autenticacao/domain/models/terminal_do_usuario.dart';

abstract class ITerminaisDoUsuarioRemoteDataSource {
  Future<List<TerminalDoUsuario>> buscarTerminaisDoUsuario(
    int usuarioId,
    int idEmpresa,
  );

  Future<void> vincularTerminalAoUsuario({
    required int usuarioId,
    required int terminalId,
    required int idEmpresa,
  });

  Future<void> desvincularTerminalDoUsuario({
    required int usuarioId,
    required int terminalId,
  });
}
