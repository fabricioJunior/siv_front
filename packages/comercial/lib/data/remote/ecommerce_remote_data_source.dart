import 'package:comercial/data/remote/dtos/ecommerce_dto.dart';
import 'package:comercial/data/remote/dtos/ecommerce_referencia_dto.dart';
import 'package:comercial/data/remote/dtos/ecommerce_referencia_produto_dto.dart';
import 'package:comercial/domain/data/remote/i_ecommerce_remote_data_source.dart';
import 'package:comercial/models.dart';
import 'package:core/remote_data_sourcers.dart';

class EcommerceRemoteDataSource extends RemoteDataSourceBase
    implements IEcommerceRemoteDataSource {
  EcommerceRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/e-commerce/{id}';

  @override
  Future<List<Ecommerce>> recuperarEcommerces({
    bool incluirApagados = false,
  }) async {
    final response = await get(
      pathParameters: const {'id': ''},
      queryParameters: {'incluirApagados': incluirApagados.toString()},
    );
    return (response.body as List<dynamic>)
        .map((json) => EcommerceDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Ecommerce> recuperarEcommerce(int id) async {
    final response = await get(pathParameters: {'id': id.toString()});
    return EcommerceDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Ecommerce> criarEcommerce(Ecommerce ecommerce) async {
    final response = await post(
      pathParameters: const {'id': ''},
      body: EcommerceDto(
        empresaId: ecommerce.empresaId,
        titulo: ecommerce.titulo,
        subtitulo: ecommerce.subtitulo,
        descricao: ecommerce.descricao,
        icone: ecommerce.icone,
        empresaEstoqueId: ecommerce.empresaEstoqueId,
        tabelaDePrecoId: ecommerce.tabelaDePrecoId,
        terminalId: ecommerce.terminalId,
        formasDePagamentoIds: ecommerce.formasDePagamentoIds,
      ).toJson(),
    );
    return EcommerceDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<Ecommerce> atualizarEcommerce(Ecommerce ecommerce) async {
    final response = await put(
      pathParameters: {'id': ecommerce.id.toString()},
      body: EcommerceDto(
        id: ecommerce.id,
        empresaId: ecommerce.empresaId,
        titulo: ecommerce.titulo,
        subtitulo: ecommerce.subtitulo,
        descricao: ecommerce.descricao,
        icone: ecommerce.icone,
        empresaEstoqueId: ecommerce.empresaEstoqueId,
        tabelaDePrecoId: ecommerce.tabelaDePrecoId,
        terminalId: ecommerce.terminalId,
        formasDePagamentoIds: ecommerce.formasDePagamentoIds,
      ).toJson(),
    );
    return EcommerceDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> excluirEcommerce(int id) async {
    await delete(pathParameters: {'id': id.toString()});
  }

  @override
  Future<void> restaurarEcommerce(int id) async {
    await put(
      pathParameters: {'id': '$id/restaurar'},
      body: const <String, dynamic>{},
    );
  }

  @override
  Future<List<EcommerceReferencia>> recuperarReferencias(
    int ecommerceId, {
    String? busca,
  }) async {
    final response = await get(
      pathParameters: {'id': '$ecommerceId/referencias'},
      queryParameters: {
        'limit': '200',
        if (busca != null && busca.trim().isNotEmpty) 'search': busca.trim(),
      },
    );
    final body = response.body as Map<String, dynamic>;
    return (body['items'] as List<dynamic>)
        .map(
          (json) =>
              EcommerceReferenciaDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<EcommerceReferencia> adicionarReferencia(
    int ecommerceId, {
    required int referenciaId,
    int? tabelaDePrecoId,
  }) async {
    final response = await post(
      pathParameters: {'id': '$ecommerceId/referencias'},
      body: {
        'referenciaId': referenciaId,
        if (tabelaDePrecoId != null) 'tabelaDePrecoId': tabelaDePrecoId,
      },
    );
    return EcommerceReferenciaDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  @override
  Future<EcommerceReferencia> atualizarReferencia(
    int ecommerceId,
    int id, {
    bool? rascunho,
    int? tabelaDePrecoId,
  }) async {
    final response = await patch(
      pathParameters: {'id': '$ecommerceId/referencias/$id'},
      body: {
        if (rascunho != null) 'rascunho': rascunho,
        if (tabelaDePrecoId != null) 'tabelaDePrecoId': tabelaDePrecoId,
      },
    );
    return EcommerceReferenciaDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  @override
  Future<List<EcommerceReferenciaProduto>> recuperarProdutosDaReferencia(
    int ecommerceId,
    int referenciaId,
  ) async {
    final response = await get(
      pathParameters: {
        'id': '$ecommerceId/referencias/$referenciaId/produtos',
      },
    );
    return (response.body as List<dynamic>)
        .map(
          (json) => EcommerceReferenciaProdutoDto.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> atualizarDisponibilidadeProduto(
    int ecommerceId,
    int referenciaId,
    int produtoId, {
    required bool disponivel,
  }) async {
    await put(
      pathParameters: {
        'id': '$ecommerceId/referencias/$referenciaId/produtos/$produtoId',
      },
      body: {'disponivel': disponivel},
    );
  }
}
