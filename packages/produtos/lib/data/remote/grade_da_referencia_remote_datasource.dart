import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/data/remote/i_grade_da_referencia_remote_data_source.dart';
import 'package:produtos/models.dart';

import 'dtos/grade_da_referencia_dto.dart';

class GradeDaReferenciaRemoteDatasource extends RemoteDataSourceBase
    implements IGradeDaReferenciaRemoteDataSource {
  GradeDaReferenciaRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/produtos/referencia/{referenciaId}/grade';

  @override
  Future<GradeDaReferencia> fetchGrade({
    required int referenciaId,
    int? tabelaDePrecoId,
  }) async {
    final response = await get(
      pathParameters: {'referenciaId': referenciaId.toString()},
      queryParameters: {
        if (tabelaDePrecoId != null)
          'tabelaDePrecoId': tabelaDePrecoId.toString(),
      },
    );

    return GradeDaReferenciaDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }
}
