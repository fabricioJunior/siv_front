import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/dtos/contagem_do_caixa_dto.dart';
import 'package:financeiro/domain/data/remote/i_contagem_do_caixa_remote_data_source.dart';
import 'package:financeiro/domain/models/contagem_do_caixa.dart';

class ContagemDoCaixaRemoteDataSource extends RemoteDataSourceBase
    implements IContagemDoCaixaRemoteDataSource {
  ContagemDoCaixaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas/{caixaId}/contagem';

  @override
  Future<ContagemDoCaixa?> recuperarContagemDoCaixa({
    required int caixaId,
  }) async {
    try {
      final response = await get(
        pathParameters: {'caixaId': caixaId.toString()},
      );

      if (response.statusCode == 404 ||
          response.body == null ||
          response.body == '') {
        return null;
      }

      return ContagemDoCaixaDto.fromJson(
        response.body as Map<String, dynamic>,
        caixaId: caixaId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> salvarItemDaContagemDoCaixa({
    required int caixaId,
    required ContagemDoCaixa contagemDoCaixa,
  }) async {
    await post(
      pathParameters: {'caixaId': caixaId.toString()},
      body: {
        'id': contagemDoCaixa.id,
        'caixaId': contagemDoCaixa.caixaId,
        'observacao': contagemDoCaixa.observacao,
        'itens': contagemDoCaixa.itens
            .map(
              (item) => {
                'id': item.id,
                'tipo': item.tipo.name,
                'valor': item.valor,
              },
            )
            .toList(),
      },
    );
  }
}
