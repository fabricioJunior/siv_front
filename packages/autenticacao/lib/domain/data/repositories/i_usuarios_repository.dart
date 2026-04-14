import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:autenticacao/domain/models/usuario.dart';

abstract class IUsuariosRepository {
  Future<Iterable<Usuario>> getUsuarios();

  Future<Usuario?> getUsuario({
    int? id,
  });

  Future<Usuario> getUsuarioDaSessao();

  Future<Usuario?> getUsuarioDaSessaoSalvo();

  Future<TerminalDoUsuario?> getTerminalDaSessaoSalvo();

  Future<void> salvarUsuarioDaSessao(Usuario usuario);

  Future<void> salvarTerminalDaSessao(TerminalDoUsuario terminal);

  Future<void> apagarUsuarioDaSessao();

  Future<void> limparTerminalDaSessao();

  Future<List<TerminalDoUsuario>> buscarTerminaisDoUsuario({
    required int usuarioId,
    required int idEmpresa,
  });

  Future<List<TerminalDoUsuario>> buscarTerminaisDaEmpresa({
    required int idEmpresa,
  });

  Future<void> desvincularTerminalDoUsuario({
    required int usuarioId,
    required int terminalId,
  });
  Future<void> vincularTerminalAoUsuario({
    required int usuarioId,
    required int terminalId,
    required int idEmpresa,
  });

  Future<Usuario> salvarUsuario({
    int? id,
    String? login,
    required String nome,
    String? usuario,
    String? senha,
    required TipoUsuario tipo,
    required bool ativo,
  });
}
