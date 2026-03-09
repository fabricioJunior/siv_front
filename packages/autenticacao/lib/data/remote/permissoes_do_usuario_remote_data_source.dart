import 'package:autenticacao/data/remote/dtos/permissao_do_usuario_dto.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_do_usuario_remote_data_source.dart';
import 'package:autenticacao/models.dart';
import 'package:core/remote_data_sourcers.dart';

class PermissoesDoUsuarioRemoteDataSource extends RemoteDataSourceBase
    implements IPermissoesDoUsuarioRemoteDataSource {
  PermissoesDoUsuarioRemoteDataSource({required super.informacoesParaRequest});

  @override
  Future<List<PermissaoDoUsuario>> getPermissoes(int idUsuario) async {
    var pathParameters = {
      'id': idUsuario.toString(),
    };
    final response = await get(pathParameters: pathParameters);

    final jsonResponse = response.body as List;

    return jsonResponse
        .map((json) =>
            PermissaoDoUsuarioDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  String get path => 'v1/usuarios/{id}/acessos';
}
