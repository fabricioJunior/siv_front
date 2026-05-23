import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/dtos/sangria_dto.dart';
import 'package:financeiro/domain/data/remote/i_sangrias_remote_data_source.dart';
import 'package:financeiro/domain/models/sangria.dart';

class SangriasRemoteDataSource extends RemoteDataSourceBase
    implements ISangriasRemoteDataSource {
  SangriasRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas/{caixaId}/sangrias/{id}';

  @override
  Future<Sangria> criarSangria({
    required int caixaId,
    required double valor,
    required String descricao,
    required String origem,
  }) async {
    final response = await post(
      pathParameters: {'caixaId': caixaId.toString()},
      body: {
        'valor': valor,
        'descricao': descricao,
        'origem': origem,
      },
    );

    final body = response.body;
    if (body is Map<String, dynamic>) {
      return SangriaDto.fromJson(body);
    }

    return Sangria.create(
      caixaId: caixaId,
      valor: valor,
      descricao: descricao,
      origem: origem,
    );
  }

  @override
  Future<Sangria> recuperarSangria({
    required int sangriaId,
    required int caixaId,
  }) async {
    final response = await get(
      pathParameters: {
        'caixaId': caixaId.toString(),
        'id': sangriaId.toString(),
      },
    );

    return SangriaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<Sangria>> recuperarSangrias({required int caixaId}) async {
    final response = await get(
      pathParameters: {'caixaId': caixaId.toString()},
    );

    if (response.statusCode == 204 ||
        response.body == null ||
        response.body == '') {
      return [];
    }

    return (response.body as List<dynamic>)
        .map((item) => SangriaDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cancelarSangria({
    required int sangriaId,
    required int caixaId,
    required String motivo,
  }) async {
    await put(
      pathParameters: {
        'caixaId': caixaId.toString(),
        'id': '$sangriaId/cancelar',
      },
      body: {
        'motivo': motivo,
        'motivoCancelamento': motivo,
      },
    );
  }
}
