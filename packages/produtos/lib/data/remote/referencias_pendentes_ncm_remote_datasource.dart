import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/data/remote/dtos/referencia_dto.dart';
import 'package:produtos/domain/data/remote/i_referencias_pendentes_ncm_remote_data_source.dart';

class ReferenciasPendentesNcmRemoteDatasource extends RemoteDataSourceBase
    implements IReferenciasPendentesNcmRemoteDataSource {
  ReferenciasPendentesNcmRemoteDatasource({
    required super.informacoesParaRequest,
  });

  @override
  String get path => '/v1/referencias/{segmento}';

  @override
  Future<ReferenciasSemNcmResultado> fetchReferenciasSemNcm({
    String? search,
    String orderBy = 'nome',
    String orderDir = 'ASC',
    int page = 1,
  }) async {
    final response = await get(
      pathParameters: {'segmento': 'sem-ncm'},
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        'orderBy': orderBy,
        'orderDir': orderDir,
        'page': page.toString(),
      },
    );

    final body = response.body as Map<String, dynamic>;
    final meta = body['meta'] as Map<String, dynamic>;
    final rawItems = body['items'] as List<dynamic>;

    return ReferenciasSemNcmResultado(
      items: rawItems
          .map((e) => ReferenciaDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (meta['totalItems'] as num).toInt(),
      totalPages: (meta['totalPages'] as num).toInt(),
      currentPage: (meta['currentPage'] as num).toInt(),
    );
  }

  @override
  Future<AtualizarNcmEmMassaResultado> atualizarNcmEmMassa() async {
    final response = await patch(
      pathParameters: {'segmento': 'atualizar-ncm-em-massa'},
      body: {},
    );

    final body = response.body as Map<String, dynamic>;
    return AtualizarNcmEmMassaResultado(
      atualizadas: (body['atualizadas'] as num).toInt(),
      ignoradas: (body['ignoradas'] as num).toInt(),
    );
  }
}
