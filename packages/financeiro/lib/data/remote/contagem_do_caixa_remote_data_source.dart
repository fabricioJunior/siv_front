import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data.dart';
import 'package:financeiro/domain/models/contagem_do_caixa.dart';

class ContagemDoCaixaRemoteDataSource extends RemoteDataSourceBase
    implements IContagemDoCaixaRemoteDataSource {
  ContagemDoCaixaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas/{caixaId}/contagem/{pendente}';

  @override
  Future<ContagemDoCaixa?> recuperarContagemDoCaixa({
    required int caixaId,
  }) async {
    final response = await get(
      pathParameters: {'caixaId': caixaId.toString()},
    );

    if (response.statusCode == 404 ||
        response.body == null ||
        response.body == '') {
      return null;
    }

    final body = response.body;
    if (body is! Map<String, dynamic>) {
      throw FormatException(
        'Formato invalido da resposta de contagem do caixa: ${body.runtimeType}',
      );
    }

    return ContagemDoCaixaDto.fromJson(
      body,
      caixaId: caixaId,
    );
  }

  @override
  Future<void> encerrarContagemDoCaixa({required int caixaId}) async {
    await post(
      pathParameters: {
        'caixaId': caixaId.toString(),
        'pendente': 'encerrar',
      },
      body: const {},
    );
  }

  @override
  Future<ContagemDoCaixa> criarItemDaContagemDoCaixa({
    required int caixaId,
    required ContagemDoCaixa contagemDoCaixa,
  }) async {
    final response = await post(
      pathParameters: {'caixaId': caixaId.toString()},
      body: {
        'id': contagemDoCaixa.id,
        'caixaId': contagemDoCaixa.caixaId,
        'observacao': contagemDoCaixa.observacao,
        'items': contagemDoCaixa.itens
            .map(
              (item) => {
                'id': item.id,
                'tipoDocumento': item.tipoDocumento.name,
                'valor': item.valor,
              },
            )
            .toList(),
      },
    );

    return ContagemDoCaixaDto.fromJson(
      response.body as Map<String, dynamic>,
      caixaId: caixaId,
    );
  }

  @override
  Future<List<ContagemDoCaixaItemDto>>
      recuperarItensPendentesParaContagemDoCaixa({
    required int caixaId,
  }) async {
    final pathParameters = {
      'caixaId': caixaId.toString(),
      'pendente': 'pendentes',
    };
    final response = await get(
      pathParameters: pathParameters,
    );
    final body = response.body;
    if (body is! List) {
      throw FormatException(
        'Formato invalido da resposta de pendentes: ${body.runtimeType}',
      );
    }

    return body
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw FormatException(
              'Item pendente com formato invalido: ${item.runtimeType}',
            );
          }
          return ContagemDoCaixaItemDto.fromJson(item);
        })
        .toList();
  }
  
  @override
  Future<ContagemDoCaixa?> recuperarContagemDoCaixaRealizada({
    required int idCaixa,
  }) async {
    final pathParameters = {
      'caixaId': idCaixa.toString(),
    };
    final response = await get(
      pathParameters: pathParameters,
    );

    if (response.statusCode == 404 ||
        response.body == null ||
        response.body == '') {
      return null;
    }

    final body = response.body;
    if (body is! Map<String, dynamic>) {
      throw FormatException(
        'Formato invalido da resposta de contagem do caixa realizada: ${body.runtimeType}',
      );
    }

    return ContagemDoCaixaDto.fromJson(
      body,
      caixaId: idCaixa,
    );
  }
  
  @override
  Future<ContagemDoCaixa> atualizarContagemDoCaixa({
    required int caixaId,
    required ContagemDoCaixa contagemDoCaixa,
  }) async {
    final response = await put(
      pathParameters: {'caixaId': caixaId.toString()},
      body: {
        'id': contagemDoCaixa.id,
        'caixaId': contagemDoCaixa.caixaId,
        'observacao': contagemDoCaixa.observacao,
        'items': contagemDoCaixa.itens
            .map(
              (item) => {
                'id': item.id,
                'tipoDocumento': item.tipoDocumento.name,
                'valor': item.valor,
              },
            )
            .toList(),
      },
    );

    return ContagemDoCaixaDto.fromJson(
      response.body as Map<String, dynamic>,
      caixaId: caixaId,
    );
  }
}
