import 'package:core/remote_data_sourcers.dart';
import 'package:empresas/data/remote_data_sourcers/dtos/terminal_dto.dart';
import 'package:empresas/domain/data/remote_data_sourcers/i_terminais_remote_data_source.dart';
import 'package:empresas/domain/entities/terminal.dart';

class TerminaisRemoteDataSource extends RemoteDataSourceBase
    implements ITerminaisRemoteDataSource {
  TerminaisRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/empresas/{empresaId}/terminais/{id}';

  @override
  Future<Terminal> atualizarTerminal({
    required int empresaId,
    required int id,
    required String nome,
  }) async {
    final response = await put(
      pathParameters: {'empresaId': empresaId.toString(), 'id': id.toString()},
      body: {'empresaId': empresaId, 'nome': nome},
    );

    return TerminalDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Terminal> criarTerminal({
    required int empresaId,
    required String nome,
  }) async {
    final response = await post(
      pathParameters: {'empresaId': empresaId.toString()},
      body: {'empresaId': empresaId, 'nome': nome},
    );

    return TerminalDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> desativarTerminal({
    required int empresaId,
    required int id,
  }) async {
    final response = await delete(
      pathParameters: {'empresaId': empresaId.toString(), 'id': id.toString()},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao desativar terminal');
    }
  }

  @override
  Future<Terminal?> recuperarTerminal({
    required int empresaId,
    required int id,
  }) async {
    final response = await get(
      pathParameters: {'empresaId': empresaId.toString(), 'id': id.toString()},
    );

    return TerminalDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<Terminal>> recuperarTerminais({
    required int empresaId,
    String? nome,
    bool? inativo,
  }) async {
    final response = await get(
      pathParameters: {'empresaId': empresaId.toString()},
      queryParameters: {
        if (nome != null && nome.trim().isNotEmpty) 'nome': nome,
        if (inativo != null) 'inativo': inativo.toString(),
      },
    );

    return (response.body as List<dynamic>)
        .map((item) => TerminalDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
