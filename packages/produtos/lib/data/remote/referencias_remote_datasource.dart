import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/data/remote/i_referencias_remote_data_source.dart';
import 'package:produtos/models.dart';

import 'dtos/referencia_dto.dart';

class ReferenciasRemoteDatasource extends RemoteDataSourceBase
    implements IReferenciasRemoteDataSource {
  ReferenciasRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/referencias/{id}';

  @override
  Future<List<Referencia>> fetchReferencias({
    String? nome,
    bool? inativo,
  }) async {
    var response = await get(
      queryParameters: {
        if (nome != null) 'nome': nome,
        if (inativo != null) 'inativo': inativo.toString(),
      },
    );

    return (response.body as List<dynamic>)
        .map((e) => ReferenciaDto.fromJson(e))
        .toList();
  }
}
