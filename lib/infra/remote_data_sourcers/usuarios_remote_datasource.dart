import 'package:autenticacao/domain/data/data_sourcers/remote/i_usuarios_remote_data_source.dart';
import 'package:autenticacao/domain/models/usuario.dart';
import 'package:core/remote_data_sourcers.dart';

import 'dtos/usuario_dto.dart';

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
  Future<void> postUsuario(Usuario usuario) {
    return post(body: usuario.toDto().toJson());
  }

  @override
  String get path => 'v1/usuarios/{id}';
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
