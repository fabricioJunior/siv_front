import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import 'package:autenticacao/domain/models/terminal_do_usuario.dart';

class RecuperarTerminaisDoUsuarioPorEmpresa {
  final IUsuariosRepository _usuariosRepository;

  RecuperarTerminaisDoUsuarioPorEmpresa({
    required IUsuariosRepository usuariosRepository,
  }) : _usuariosRepository = usuariosRepository;

  Future<List<TerminalDoUsuario>> call({
    required int idUsuario,
    required int idEmpresa,
  }) {
    return _usuariosRepository.buscarTerminaisDoUsuario(
      usuarioId: idUsuario,
      idEmpresa: idEmpresa,
    );
  }
}
