import 'package:autenticacao/data.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_usuarios_remote_data_source.dart';
import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:autenticacao/domain/models/usuario.dart';

class UsuariosRepository implements IUsuariosRepository {
  final IUsuariosRemoteDataSource usuariosRemoteDataSource;
  final IUsuarioDaSessaoRemoteDataSource usuarioDaSessaoRemoteDataSource;
  final IUsuarioDaSessaoLocalDataSource usuarioDaSessaoLocalDataSource;
  final ITerminaisDoUsuarioRemoteDataSource terminaisDoUsuarioRemoteDataSource;
  final ITerminaisDaEmpresaRemoteDataSource terminaisDaEmpresaRemoteDataSource;

  UsuariosRepository({
    required this.usuariosRemoteDataSource,
    required this.usuarioDaSessaoRemoteDataSource,
    required this.usuarioDaSessaoLocalDataSource,
    required this.terminaisDoUsuarioRemoteDataSource,
    required this.terminaisDaEmpresaRemoteDataSource,
  });

  @override
  Future<Iterable<Usuario>> getUsuarios() {
    return usuariosRemoteDataSource.getUsuarios();
  }

  @override
  Future<Usuario?> getUsuario({int? id}) {
    assert(id != null, 'informe algum parâmetro para buscar o usuário');

    return usuariosRemoteDataSource.getUsuario(id: id);
  }

  @override
  Future<Usuario> getUsuarioDaSessao() {
    return usuarioDaSessaoRemoteDataSource.getUsuario();
  }

  @override
  Future<void> apagarUsuarioDaSessao() async {
    await usuarioDaSessaoLocalDataSource.deleteAll();
  }

  @override
  Future<List<TerminalDoUsuario>> buscarTerminaisDaEmpresa({
    required int idEmpresa,
  }) {
    return terminaisDaEmpresaRemoteDataSource.buscarTerminaisDaEmpresa(
      idEmpresa,
    );
  }

  @override
  Future<List<TerminalDoUsuario>> buscarTerminaisDoUsuario({
    required int usuarioId,
    required int idEmpresa,
  }) {
    return terminaisDoUsuarioRemoteDataSource.buscarTerminaisDoUsuario(
      usuarioId,
      idEmpresa,
    );
  }

  @override
  Future<void> desvincularTerminalDoUsuario({
    required int usuarioId,
    required int terminalId,
  }) {
    return terminaisDoUsuarioRemoteDataSource.desvincularTerminalDoUsuario(
      usuarioId: usuarioId,
      terminalId: terminalId,
    );
  }

  @override
  Future<Usuario?> getUsuarioDaSessaoSalvo() async {
    var all = await usuarioDaSessaoLocalDataSource.fetchAll();
    return all.isEmpty ? null : all.first;
  }

  @override
  Future<void> salvarUsuarioDaSessao(Usuario usuario) {
    return usuarioDaSessaoLocalDataSource.put(usuario);
  }

  @override
  Future<void> vincularTerminalAoUsuario({
    required int usuarioId,
    required int terminalId,
    required int idEmpresa,
  }) {
    return terminaisDoUsuarioRemoteDataSource.vincularTerminalAoUsuario(
      usuarioId: usuarioId,
      terminalId: terminalId,
      idEmpresa: idEmpresa,
    );
  }

  @override
  Future<Usuario> salvarUsuario({
    int? id,
    String? login,
    required String nome,
    String? senha,
    required TipoUsuario tipo,
    String? usuario,
    required bool ativo,
  }) {
    if (id != null) {
      return usuariosRemoteDataSource.putUsuario(
        id: id,
        login: login,
        nome: nome,
        senha: senha,
        tipo: tipo,
        ativo: ativo,
      );
    }
    return usuariosRemoteDataSource.postUsuario(
      id: id,
      login: login,
      nome: nome,
      senha: senha,
      tipo: tipo,
      ativo: ativo,
      usuario: usuario!,
    );
  }
}
