import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_do_usuario_remote_data_source.dart';
import 'package:autenticacao/domain/models/permissao.dart';
import 'package:core/remote_data_sourcers.dart';

import 'dtos/permissao_dto.dart';

class PermissoesDoUsuarioRemoteDataSource extends RemoteDataSourceBase
    implements IPermissoesDoUsuarioRemoteDataSource {
  PermissoesDoUsuarioRemoteDataSource({required super.informacoesParaRequest});

  @override
  Future<List<Permissao>> getPermissoes(int idUsuario) async {
    var pathParameters = {
      'id': idUsuario.toString(),
    };
    final response = await get(pathParameters: pathParameters);

    final jsonResponse = response.body as List;

    return jsonResponse
        .map((json) => PermissaoDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  String get path => 'usuarios/{id}/permissoes';
}
