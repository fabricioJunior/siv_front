import 'package:autenticacao/data/remote/dtos/terminal_do_usuario_dto.dart';
import 'package:autenticacao/domain/data/data_sourcers/remote/i_terminais_do_usuario_remote_data_source.dart';
import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:core/remote_data_sourcers.dart';

class TerminaisDoUsuarioRemoteDataSource extends RemoteDataSourceBase
    implements ITerminaisDoUsuarioRemoteDataSource {
  TerminaisDoUsuarioRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/usuarios/{usuarioId}/terminais/{id}';

  @override
  Future<List<TerminalDoUsuario>> buscarTerminaisDoUsuario(
    int usuarioId,
    int idEmpresa,
  ) async {
    final response = await get(
      pathParameters: {'usuarioId': usuarioId.toString()},
      queryParameters: {'id': idEmpresa.toString()},
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

  @override
  Future<void> desvincularTerminalDoUsuario({
    required int usuarioId,
    required int terminalId,
  }) {
    return delete(
      pathParameters: {
        'usuarioId': usuarioId.toString(),
        'id': terminalId.toString(),
      },
    );
  }

  @override
  Future<void> vincularTerminalAoUsuario({
    required int usuarioId,
    required int terminalId,
    required int idEmpresa,
  }) {
    return post(
      pathParameters: {'usuarioId': usuarioId.toString()},
      body: {'terminalId': terminalId, 'empresaId': idEmpresa},
    );
  }
}
