import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import 'package:autenticacao/domain/models/terminal_do_usuario.dart';

class RecuperarTerminaisDaEmpresa {
  final IUsuariosRepository _usuariosRepository;

  RecuperarTerminaisDaEmpresa({
    required IUsuariosRepository usuariosRepository,
  }) : _usuariosRepository = usuariosRepository;

  Future<List<TerminalDoUsuario>> call({required int idEmpresa}) {
    return _usuariosRepository.buscarTerminaisDaEmpresa(idEmpresa: idEmpresa);
  }
}
