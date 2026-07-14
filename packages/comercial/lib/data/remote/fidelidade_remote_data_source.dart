import 'package:comercial/domain/data/remote/i_fidelidade_remote_data_source.dart';
import 'package:core/remote_data_sourcers.dart';

class FidelidadeRemoteDataSource extends RemoteDataSourceBase
    implements IFidelidadeRemoteDataSource {
  FidelidadeRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/pessoas/{pessoaId}/elegivel-fidelidade';

  @override
  Future<bool> verificarElegibilidade({required int pessoaId}) async {
    final response = await get(
      pathParameters: {'pessoaId': pessoaId},
    );

    final body = response.body;
    if (body is Map<String, dynamic>) {
      return body['elegivel'] == true;
    }

    return false;
  }
}
