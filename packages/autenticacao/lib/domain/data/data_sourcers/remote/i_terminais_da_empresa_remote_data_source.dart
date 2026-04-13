import 'package:autenticacao/domain/models/terminal_do_usuario.dart';

abstract class ITerminaisDaEmpresaRemoteDataSource {
  Future<List<TerminalDoUsuario>> buscarTerminaisDaEmpresa(int idEmpresa);
}
