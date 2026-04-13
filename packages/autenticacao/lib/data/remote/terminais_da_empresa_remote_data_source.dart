import 'package:autenticacao/data/remote/dtos/terminal_do_usuario_dto.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_terminais_da_empresa_remote_data_source.dart';
import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:core/remote_data_sourcers.dart';

class TerminaisDaEmpresaRemoteDataSource extends RemoteDataSourceBase
    implements ITerminaisDaEmpresaRemoteDataSource {
  TerminaisDaEmpresaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/empresas/{empresaId}/terminais/{id}';

  @override
  Future<List<TerminalDoUsuario>> buscarTerminaisDaEmpresa(
      int idEmpresa) async {
    final response = await get(
      pathParameters: {'empresaId': idEmpresa.toString()},
    );

    if (response.statusCode == 204 ||
        response.body == null ||
        response.body == '') {
      return [];
    }

    return (response.body as List<dynamic>)
        .map((item) =>
            TerminalDoUsuarioDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
