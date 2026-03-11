import 'package:core/remote_data_sourcers.dart';
import 'package:empresas/data/remote_data_sourcers/dtos/empresa_parametro_dto.dart';
import 'package:empresas/domain/data/remote_data_sourcers/i_empresa_parametro_remote_data_source.dart';
import 'package:empresas/domain/entities/empresa_parametro.dart';

class EmpresaParametroRemoteDataSource extends RemoteDataSourceBase
    implements IEmpresaParametroRemoteDataSource {
  EmpresaParametroRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/empresas/{empresaId}/parametros/{idComponente}';

  @override
  Future<List<EmpresaParametro>> recuperarParametros(int empresaId) async {
    final response = await get(
      pathParameters: {'empresaId': empresaId.toString()},
    );

    final body = response.body as List;
    return body
        .map(
          (item) => EmpresaParametroDto.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<EmpresaParametro>> atualizarParametros({
    required int empresaId,
    required List<EmpresaParametro> parametros,
  }) async {
    for (var parametro in parametros) {
      final response = await put(
        pathParameters: {
          'empresaId': empresaId.toString(),
          'idComponente': parametro.chave,
        },
        body: parametro.toDto().toJson(),
      );
      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar o parâmetro ${parametro.chave}');
      }
    }

    return recuperarParametros(empresaId);
  }
}
