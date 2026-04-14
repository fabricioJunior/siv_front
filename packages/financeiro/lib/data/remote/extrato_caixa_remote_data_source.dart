import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/dtos/extrato_caixa_dto.dart';
import 'package:financeiro/domain/data/remote/i_extrato_caixa_remote_data_source.dart';
import 'package:financeiro/domain/models/extrato_caixa.dart';

class ExtratoCaixaRemoteDataSource extends RemoteDataSourceBase
    implements IExtratoCaixaRemoteDataSource {
  ExtratoCaixaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas/{caixaId}/extrato/{documento}';

  @override
  Future<List<ExtratoCaixa>> buscarExtratoCaixa({required int caixaId}) async {
    final response = await get(
      pathParameters: {'caixaId': caixaId.toString()},
    );

    if (response.statusCode == 204 ||
        response.body == null ||
        response.body == '') {
      return [];
    }

    return (response.body as List<dynamic>)
        .map((item) => ExtratoCaixaDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ExtratoCaixa>> buscarExtratoCaixaPorDocumento({
    required int caixaId,
    required String documento,
  }) async {
    final response = await get(
      pathParameters: {
        'caixaId': caixaId.toString(),
        'documento': documento,
      },
    );

    if (response.statusCode == 204 ||
        response.body == null ||
        response.body == '') {
      return [];
    }

    return (response.body as List<dynamic>)
        .map((item) => ExtratoCaixaDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
