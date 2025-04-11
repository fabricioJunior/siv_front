import 'package:autenticacao/domain/data/data_sourcers/remote/i_permissoes_remote_data_source.dart';
import 'package:autenticacao/domain/models/permissao.dart';
import 'package:core/remote_data_sourcers.dart';

import 'dtos/permissao_dto.dart';

class PermissoesRemoteDataSource extends RemoteDataSourceBase
    implements IPermissoesRemoteDataSource {
  PermissoesRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => 'componentes';

  @override
  Future<Iterable<Permissao>> getPermissoes() async {
    var response = await get();

    var jsonResponse = response.body as List;

    return jsonResponse
        .map((json) => PermissaoDto.fromJson(json as Map<String, dynamic>));
  }
}
