import 'package:autenticacao/domain/data/data_sourcers/remote/i_usuarios_remote_data_source.dart';
import 'package:autenticacao/domain/models/usuario.dart';
import 'package:core/remote_data_sourcers.dart';

import 'dtos/usuario_dto.dart';
import 'dtos/usuario_to_edit_dto.dart';

class UsuariosRemoteDatasource extends RemoteDataSourceBase
    implements IUsuariosRemoteDataSource {
  UsuariosRemoteDatasource({required super.informacoesParaRequest});

  @override
  Future<Usuario?> getUsuario({int? id}) async {
    var pathParameters = {'id': id};
    var response = await get(
      pathParameters: pathParameters,
    );
    if (response.body == null) {
      return null;
    }
    return UsuarioDto.fromJson(response.body);
  }

  @override
  Future<Iterable<Usuario>> getUsuarios() async {
    var response = await get();

    List<dynamic> body = response.body;
    return body.map((json) => UsuarioDto.fromJson(json)).toList();
  }

  @override
  Future<Usuario> postUsuario({
    int? id,
    String? login,
    required String nome,
    required String usuario,
    String? senha,
    required TipoUsuario tipo,
    required bool ativo,
  }) async {
    var usuarioToPost = UsarioToEditDto(
      id: id,
      login: id != null ? null : login,
      nome: nome,
      senha: senha,
      tipo: tipo,
      situacao: ativo ? 'ativo' : 'invativo',
    );
    var response = await post(body: usuarioToPost.toJson());

    return UsuarioDto.fromJson(response.body);
  }

  @override
  String get path => 'v1/usuarios/{id}';

  @override
  Future<Usuario> putUsuario({
    required int id,
    String? login,
    required String nome,
    String? senha,
    required TipoUsuario tipo,
    required bool ativo,
  }) async {
    var pathParameters = {'id': id};

    var usuarioToPost = UsarioToEditDto(
      id: id,
      login: login,
      nome: nome,
      senha: senha,
      tipo: tipo,
      situacao: ativo ? 'ativo' : 'invativo',
    );
    var response =
        await put(body: usuarioToPost.toJson(), pathParameters: pathParameters);

    return UsuarioDto.fromJson(response.body);
  }
}

extension ToDto on Usuario {
  UsuarioDto toDto() => UsuarioDto(
        id: id,
        login: login,
        nome: nome,
        tipo: tipo,
        senha: senha,
      );
}
