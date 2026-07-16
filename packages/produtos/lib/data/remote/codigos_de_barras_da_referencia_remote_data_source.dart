import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/data/remote/dtos/codigo_barras_resumo_dto.dart';
import 'package:produtos/domain/data/remote/i_codigos_de_barras_da_referencia_remote_data_source.dart';
import 'package:produtos/domain/models/pagina_codigos_de_barras.dart';

class CodigosDeBarrasDaReferenciaRemoteDataSource extends RemoteDataSourceBase
    implements ICodigosDeBarrasDaReferenciaRemoteDataSource {
  CodigosDeBarrasDaReferenciaRemoteDataSource({
    required super.informacoesParaRequest,
  });

  @override
  String get path => '/v1/produtos/codigo-barras/lista';

  @override
  Future<PaginaCodigosDeBarras> listar({
    required int referenciaId,
    required int page,
    required int limit,
  }) async {
    final response = await get(
      queryParameters: {
        'referenciaId': referenciaId.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );
    return PaginaCodigosDeBarrasDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }
}
