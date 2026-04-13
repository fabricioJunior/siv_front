import 'package:autenticacao/domain/data/repositories/i_empresas_repository.dart';
import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import 'package:autenticacao/domain/models/terminal_do_usuario.dart';

class RecuperarTerminaisDoUsuario {
  final IUsuariosRepository _usuariosRepository;
  final IEmpresasRepository _empresasRepository;

  RecuperarTerminaisDoUsuario({
    required IUsuariosRepository usuariosRepository,
    required IEmpresasRepository empresasRepository,
  })  : _usuariosRepository = usuariosRepository,
        _empresasRepository = empresasRepository;

  Future<List<TerminalDoUsuario>> call({required int idUsuario}) async {
    final empresas = await _empresasRepository.getEmpresas();
    final terminaisPorEmpresa = await Future.wait(
      empresas.map(
        (empresa) => _usuariosRepository.buscarTerminaisDoUsuario(
          usuarioId: idUsuario,
          idEmpresa: empresa.id,
        ),
      ),
    );

    final terminaisUnicosPorId = <int, TerminalDoUsuario>{};
    for (final terminais in terminaisPorEmpresa) {
      for (final terminal in terminais) {
        terminaisUnicosPorId[terminal.id] = terminal;
      }
    }

    return terminaisUnicosPorId.values.toList();
  }
}
