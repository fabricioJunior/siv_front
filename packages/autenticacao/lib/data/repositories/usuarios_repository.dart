import 'package:autenticacao/data.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_usuarios_remote_data_source.dart';
import 'package:autenticacao/domain/data/repositories/i_usuarios_repository.dart';
import 'package:autenticacao/domain/models/usuario.dart';

class UsuariosRepository implements IUsuariosRepository {
  final IUsuariosRemoteDataSource usuariosRemoteDataSource;
  final IUsuarioDaSessaoRemoteDataSource usuarioDaSessaoRemoteDataSource;
  final IUsuarioDaSessaoLocalDataSource usuarioDaSessaoLocalDataSource;

  UsuariosRepository({
    required this.usuariosRemoteDataSource,
    required this.usuarioDaSessaoRemoteDataSource,
    required this.usuarioDaSessaoLocalDataSource,
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
  Future<Usuario?> getUsuarioDaSessaoSalvo() async {
    var all = await usuarioDaSessaoLocalDataSource.fetchAll();
    return all.isEmpty ? null : all.first;
  }

  @override
  Future<void> salvarUsuarioDaSessao(Usuario usuario) {
    return usuarioDaSessaoLocalDataSource.put(usuario);
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
