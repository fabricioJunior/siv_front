import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/dtos/suprimento_dto.dart';
import 'package:financeiro/domain/data/remote/i_suprimentos_remote_data_source.dart';
import 'package:financeiro/domain/models/suprimento.dart';

class SuprimentosRemoteDataSource extends RemoteDataSourceBase
    implements ISuprimentosRemoteDataSource {
  SuprimentosRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas/{caixaId}/suprimentos/{id}';

  @override
  Future<Suprimento> criarSuprimento({
    required int caixaId,
    required double valor,
    required String descricao,
  }) async {
    final response = await post(
      pathParameters: {'caixaId': caixaId.toString()},
      body: {
        'valor': valor,
        'descricao': descricao,
      },
    );

    final body = response.body;
    if (body is Map<String, dynamic>) {
      return SuprimentoDto.fromJson(body);
    }

    return Suprimento.create(
      caixaId: caixaId,
      valor: valor,
      descricao: descricao,
    );
  }

  @override
  Future<Suprimento> recuperarSuprimento({
    required int suprimentoId,
    required int caixaId,
  }) async {
    final response = await get(
      pathParameters: {
        'caixaId': caixaId.toString(),
        'id': suprimentoId.toString(),
      },
    );

    return SuprimentoDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<Suprimento>> recuperarSuprimentos({required int caixaId}) async {
    final response = await get(
      pathParameters: {'caixaId': caixaId.toString()},
    );

    if (response.statusCode == 204 ||
        response.body == null ||
        response.body == '') {
      return [];
    }

    return (response.body as List<dynamic>)
        .map((item) => SuprimentoDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cancelarSuprimento({
    required int suprimentoId,
    required int caixaId,
    required String motivo,
  }) async {
    await put(
      pathParameters: {
        'caixaId': caixaId.toString(),
        'id': '$suprimentoId/cancelar',
      },
      body: {
        'motivo': motivo,
        'motivoCancelamento': motivo,
      },
    );
  }
}
